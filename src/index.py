import logging


logger = logging.getLogger(__name__)
stream = logging.StreamHandler()
logger.setLevel(logging.INFO)
logger.addHandler(stream)

def hoge(a)-> int:
    return a

def main():
    logger.info(hoge(10))


if __name__=="__main__":
    main()
