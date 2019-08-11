FROM localhost:5000/tez-test

# to configure postgres as hive metastore backend
RUN apt-get update
RUN apt-get -yq install vim mariadb-server libmysql-java \
    && rm -rf /var/lib/apt/lists/*

# having ADD commands will invalidate the cache forcing hive build from trunk everytime
# copy config, sql, data files to /opt/files
RUN mkdir /opt/files
ADD hive-site.xml /opt/files/
ADD hive-log4j.properties /opt/files/
ADD store_sales.* /opt/files/
ADD datagen.py /opt/files/

# download hive
ENV HIVE_VERSION 1.2.1
ENV HIVE_HOME /usr/local/hive

ADD https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz /usr/local
RUN cd /usr/local \
    && tar -xvf apache-hive-${HIVE_VERSION}-bin.tar.gz \
    && ln -s /usr/local/apache-hive-${HIVE_VERSION}-bin ${HIVE_HOME} \ 
    && rm -f /usr/local/apache-hive-${HIVE_VERSION}-bin.tar.gz

# set hive environment
ENV HIVE_CONF $HIVE_HOME/conf
ENV PATH $PATH:$HIVE_HOME/bin
ADD hive-site.xml $HIVE_CONF/hive-site.xml
ADD hive-log4j.properties $HIVE_CONF/hive-log4j.properties

RUN cp ${HIVE_CONF}/hive-env.sh.template ${HIVE_HOME}/hive-env.sh \
    && echo 'export HIVE_CONF_DIR=${HIVE_HOME}/conf' >> ${HIVE_HOME}/conf/hive-env.sh \
    && echo 'export METASTORE_PORT=9083' >> ${HIVE_HOME}/conf/hive-env.sh
RUN mkdir -p ${HIVE_HOME}/hcatalog/sbin/../var/log \
    && mkdir /var/log/hive \
    && ln -s /var/log/hive ${HIVE_HOME}/hcatalog/sbin/../var/log

# add mysql jdbc jar to classpath
RUN ln -s /usr/share/java/mysql-connector-java.jar ${HIVE_HOME}/lib/mysql-connector-java.jar

# create hive database, user, and schema
ADD hive.sql .
RUN chmod 777 hive.sql
RUN service mysql start \
    && mysql -u root < hive.sql \
    && ${HIVE_HOME}/bin/schematool -initSchema -dbType mysql

# set permissions for hive bootstrap file
ADD hive-bootstrap.sh /etc/hive-bootstrap.sh
RUN chown root:root /etc/hive-bootstrap.sh
RUN chmod 700 /etc/hive-bootstrap.sh
