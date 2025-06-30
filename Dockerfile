FROM spark:4.0.0-scala2.13-java17-ubuntu

ENV DELTA_VERSION=4.0.0
ENV SCALA_VERSION=2.13
#ENV DELTA_JAR=delta-spark_2.13-${DELTA_VERSION}.jar
ENV DELTA_JAR=delta-spark_${SCALA_VERSION}-${DELTA_VERSION}.jar
#ENV DELTA_STORAGE_JAR=delta-storage-${DELTA_VERSION}.jar
#ENV DELTA_STORAGE_JAR=delta-storage_2.13-${DELTA_VERSION}.jar
ENV DELTA_STORAGE_JAR=delta-storage-${DELTA_VERSION}.jar
ENV DELTA_HOME=/opt/spark/jars

USER root

# Install system + Python dependencies
RUN set -ex && \
    apt-get update && \
    apt-get install -y python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip install --no-cache-dir \
    pyspark==4.0.0 \
    delta-spark==${DELTA_VERSION} \
    pandas==2.1.3 \
    numpy==1.26.4 \
    pyarrow==12.0.1 \
    requests==2.31.0 \
    matplotlib==3.8.0 \
    seaborn==0.12.2 && \
    rm -rf /root/.cache/pip

# Download Delta Lake 4.0.0 JAR (Scala 2.13 build) to Spark's jars folder
RUN curl -L -o /opt/spark/jars/${DELTA_JAR} \
    https://repo1.maven.org/maven2/io/delta/delta-spark_${SCALA_VERSION}/${DELTA_VERSION}/${DELTA_JAR} && \
    curl -L -o /opt/spark/jars/${DELTA_STORAGE_JAR} \
    https://repo1.maven.org/maven2/io/delta/delta-storage/${DELTA_VERSION}/${DELTA_STORAGE_JAR}    

# Fix Ivy cache permission issue for --packages (if ever needed)
RUN mkdir -p /home/spark/.ivy2.5.2/cache && \
    chown -R spark:spark /home/spark/.ivy2.5.2

USER spark

# Optional: Create Spark events directory
RUN mkdir -p /tmp/spark-events
