import os
import re
import sys
import time
import requests
import asyncio

g_root = 'https://files.data.gouv.fr/cadastre/etalab-cadastre/2018-10-01/geojson/'

async def worker(name, root, dest, queue):
  loop = asyncio.get_event_loop()
  while True:
    # Get a "work item" out of the queue.
    url = await queue.get()
    print(f'{name} {url}')
    # Check wether the url points to a folder or a file
    if url[-1] == '/':
      r = await loop.run_in_executor(None, requests.get, url)
      for entry in [f'{url}{e}' for e in re.findall('href="(.*)"', r.content.decode("utf-8"), re.IGNORECASE) if '..' not in e and 'raw' not in e]:
        queue.put_nowait(entry)
    else:
      path = f'{dest}/{url[len(root):]}'
      # If the file does not yet exists, download it
      if not os.path.isfile(path):
        r = await loop.run_in_executor(None, requests.get, url)
        dirname = os.path.dirname(path)
        filename = os.path.basename(path)
        os.makedirs(dirname, exist_ok=True)
        with open(path, "bw") as file:
          file.write(r.content)

    # Notify the queue that the "work item" has been processed.
    queue.task_done()

async def main(root, dest, nbtasks):
  queue = asyncio.LifoQueue()
  queue.put_nowait(root)

  tasks = []
  for i in range(nbtasks):
    task = asyncio.create_task(worker(f'worker-{i}', root, dest, queue))
    tasks.append(task)

  started_at = time.monotonic()
  await queue.join()

  # Cancel our worker tasks.
  for task in tasks:
    task.cancel()
  # Wait until all worker tasks are cancelled.
  await asyncio.gather(*tasks, return_exceptions=True)

if len(sys.argv) != 2:
  print('error: expecting 1 argument')
  print(f'usage: {sys.argv[0]} <destination_folder>')
  sys.exit(1)

asyncio.run(main(g_root, sys.argv[1], 20))

