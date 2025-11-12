# ...existing code...
load_dotenv()

# Support multiple API keys: either GOOGLE_API_KEYS (comma-separated) or single GOOGLE_API_KEY
KEYS_RAW = os.environ.get("GOOGLE_API_KEYS") or os.environ.get("GOOGLE_API_KEY")
if not KEYS_RAW:
    print("⚠️ Warning: No GOOGLE_API_KEY or GOOGLE_API_KEYS found in environment. The script may fail when calling the model.")
API_KEYS = [k.strip() for k in KEYS_RAW.split(",") if k.strip()] if KEYS_RAW else []
DEFAULT_KEY_COOLDOWN = int(os.environ.get("KEY_COOLDOWN_SECONDS", "60"))

class ApiKeyManager:
    def __init__(self, keys, cooldown=60):
        self.keys = keys
        self.cooldown = cooldown
        # timestamp until which key i is disabled
        self.disabled_until = [0 for _ in keys]
        self.next_idx = 0

    def get_next_key(self):
        if not self.keys:
            return None, None
        n = len(self.keys)
        for i in range(n):
            idx = (self.next_idx + i) % n
            if time.time() >= self.disabled_until[idx]:
                # advance pointer for next call
                self.next_idx = (idx + 1) % n
                return self.keys[idx], idx
        return None, None

    def disable_key(self, idx, cooldown=None):
        if idx is None:
            return
        cd = cooldown if cooldown is not None else self.cooldown
        self.disabled_until[idx] = time.time() + cd


api_key_manager = ApiKeyManager(API_KEYS, DEFAULT_KEY_COOLDOWN)

# Create a helper to run the model using available keys and rotate on rate/quota errors

def run_model(prompt, model_name='gemini-2.0-flash', max_attempts=None):
    """Try to generate content using available API keys, rotating on rate/quota errors.
    Returns the model response object on success, or raises the last exception.
    """
    attempts = 0
    max_attempts = max_attempts or (max(1, len(API_KEYS)) * 3)
    last_exc = None

    while attempts < max_attempts:
        key, kidx = api_key_manager.get_next_key()
        if key is None:
            # No available keys (all cooling down) - wait then retry
            wait = api_key_manager.cooldown
            print(f"⏳ All API keys cooling down. Sleeping {wait}s before retrying...")
            time.sleep(wait)
            attempts += 1
            continue

        try:
            # Configure the SDK with the chosen key for this attempt
            genai.configure(api_key=key)
            model = genai.GenerativeModel(
                model_name,
                generation_config={
                    "temperature": 0.85,
                    "max_output_tokens": 1000,
                }
            )
            response = model.generate_content(prompt)
            return response

        except Exception as e:
            last_exc = e
            msg = str(e).lower()
            # If the error seems rate/limit related, disable the key temporarily and retry with next key
            if "429" in msg or "rate" in msg or "quota" in msg or "resourceexhausted" in msg or "exhausted" in msg:
                print(f"⚠️ API key index {kidx} hit rate/quota error: {e}. Disabling key for {api_key_manager.cooldown}s and retrying with next key.")
                api_key_manager.disable_key(kidx)
                attempts += 1
                # small backoff before next attempt
                time.sleep(1 + attempts * 0.5)
                continue
            # For other errors, re-raise (they likely require human intervention)
            raise

    # All attempts exhausted
    if last_exc:
        raise last_exc
    raise RuntimeError("Model call failed after rotating keys")

# ...existing code...

