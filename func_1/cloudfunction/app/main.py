
import os
from datetime import datetime
import logging
import google.cloud.logging

client = google.cloud.logging.Client()
client.setup_logging()
logger = logging.getLogger(name='eodhd_bulk_prices')
logger.setLevel(logging.DEBUG)




def main(request):
    data = request.get_json(silent=True)

    resu = data['result']

    logger.debug(f'{resu}')
    
       
    return resu