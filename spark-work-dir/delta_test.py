import pyspark
from delta import *
from pyspark.sql import SparkSession

builder = pyspark.sql.SparkSession.builder.appName("MyApp") \
    .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension") \
    .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog")


spark = configure_spark_with_delta_pip(builder).getOrCreate()

# Create a simple DataFrame
df = spark.range(5)
df.write.format("delta").mode("overwrite").save("/opt/spark/work-dir/test-delta-table")

# Read back from Delta table
df2 = spark.read.format("delta").load("/opt/spark/work-dir/test-delta-table")
df2.show()