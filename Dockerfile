FROM library/ubuntu:latest

USER root

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y wget software-properties-common
RUN apt-add-repository ppa:webupd8team/java && \
	echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
	apt-get update && apt-get install -y oracle-java8-installer

RUN mkdir -p /opt/otp/home/wroclaw && mkdir -p /opt/otp/jar
RUN wget -U IE8 https://repo1.maven.org/maven2/org/opentripplanner/otp/1.1.0/otp-1.1.0-shaded.jar -O /opt/otp/jar/otp.jar
RUN wget -U IE8 -O /opt/otp/jar/jython.jar http://search.maven.org/remotecontent?filepath=org/python/jython-standalone/2.7.0/jython-standalone-2.7.0.jar

RUN wget -U IE8  http://www.wroclaw.pl/open-data/opendata/rozklady/OtwartyWroclaw_rozklad_jazdy_GTFS.zip -O /opt/otp/home/wroclaw/mpk.zip
RUN wget -U IE8  http://download.bbbike.org/osm/bbbike/Wroclaw/Wroclaw.osm.pbf -O /opt/otp/home/wroclaw/Wroclaw.osm.pbf

RUN java -Xmx8G -jar /opt/otp/jar/otp.jar --build /opt/otp/home/wroclaw

EXPOSE 8080
EXPOSE 8081

ENTRYPOINT [ "java", "-Xmx6G", "-Xverify:none", "-cp", "/opt/otp/jar/otp.jar:/opt/otp/jar/jython.jar", "org.opentripplanner.standalone.OTPMain" ]

# Configure container startup
CMD ["--graphs", "/opt/otp/home/wroclaw", "--autoScan", "--server", "--analyst"]
