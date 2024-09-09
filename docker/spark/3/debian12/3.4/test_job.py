from pyspark.sql import SparkSession

def main():
    appName = "PySpark Partition Example"
    master = "local[8]"

    spark = SparkSession.builder \
        .appName(appName) \
        .master(master) \
        .getOrCreate()

    configurations = spark.sparkContext.getConf().getAll()
    for conf in configurations:
        print(conf)


if __name__ == '__main__':
    main()
