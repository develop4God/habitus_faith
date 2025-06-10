import requests
import json

API_KEY = 'daf94e6fcba47dee547625a6c2ac5e56'
BIBLE_ID = '592420522e16049f-01'
BASE_URL = 'https://api.scripture.api.bible/v1'
HEADERS = {'api-key': API_KEY}

LIBRO = 'MAT'
CAPITULOS = ['MAT.1', 'MAT.2']  # Solo los dos primeros capítulos de Mateo

def obtener_versiculos(chapter_id):
    url = f'{BASE_URL}/bibles/{BIBLE_ID}/chapters/{chapter_id}/verses'
    response = requests.get(url, headers=HEADERS)
    data = response.json()
    return [v['id'] for v in data.get('data', [])]

def obtener_texto(versiculo_id):
    url = f'{BASE_URL}/bibles/{BIBLE_ID}/verses/{versiculo_id}?content-type=text'
    response = requests.get(url, headers=HEADERS)
    data = response.json()
    if 'data' in data:
        reference = data['data']['reference']
        content = data['data']['content']
        content = content.replace('<p>', '').replace('</p>', '').strip()
        return {'reference': reference, 'text': content}
    return None

def extraer_mateo_1y2():
    resultado = {LIBRO: {}}
    for capitulo in CAPITULOS:
        print(f"Descargando capítulo: {capitulo}")
        resultado[LIBRO][capitulo] = []
        versiculos = obtener_versiculos(capitulo)
        for versiculo in versiculos:
            texto = obtener_texto(versiculo)
            if texto:
                resultado[LIBRO][capitulo].append(texto)
            else:
                print(f"  Error en versículo: {versiculo}")
    with open('mateo_1y2_rvr1960.json', 'w', encoding='utf-8') as f:
        json.dump(resultado, f, ensure_ascii=False, indent=2)
    print("¡Listo! Versículos guardados en mateo_1y2_rvr1960.json")

if __name__ == "__main__":
    extraer_mateo_1y2()