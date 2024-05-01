import requests
from bs4 import BeautifulSoup
import random
import os

url = 'https://3d-asteroids.space/asteroids'

def download_asteroids(num_asteroids):
    asteroid_list = requests.get(url)
    asteroid_list.raise_for_status() 
    
    soup = BeautifulSoup(asteroid_list.text, 'html.parser')
    
    asteroid_names = [tag.text.strip() for tag in soup.select('li')]
    asteroid_names = ['_'.join(name.replace('(', '').replace(')', '').split(' ')) for name in asteroid_names if name[0] == '(']
    selected_asteroids = random.sample(asteroid_names, num_asteroids)
        
    if not os.path.exists('Asteroids'):
        os.makedirs('Asteroids')
    
    for asteroid in selected_asteroids:
        asteroid_page = requests.get(f'{url}/{asteroid}')
        soup = BeautifulSoup(asteroid_page.text, 'html.parser')
        download_links = [(tag.text.strip(), tag.attrs.get('href')) for tag in soup.select('a')]
        download_url = [link[1] for link in download_links if ('OBJ' in link[0])][0]
        
        obj_response = requests.get(download_url)
        
        if obj_response.status_code != 200:
            print(f'Failed to download {asteroid}.obj')
            continue
        
        with open(os.path.join('Asteroids', f'{asteroid}.obj'), 'wb') as f:
            f.write(obj_response.content)
        print(f'Downloaded {asteroid}.obj')
    
    print(f'Successfully downloaded {num_asteroids} asteroids')

download_asteroids(1635)
