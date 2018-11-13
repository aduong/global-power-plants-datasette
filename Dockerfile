FROM python:3.6-slim-stretch

ADD metadata.json .

RUN apt-get update \
	&& apt-get install -y \
		curl \
		gcc \
		git \
		python3-dev \
	&& pip install csvs-to-sqlite \
	&& curl -L -o global-power-plants.csv https://raw.githubusercontent.com/wri/global-power-plant-database/master/output_database/global_power_plant_database.csv \
	&& csvs-to-sqlite global-power-plants.csv global-power-plants.db -i country_long -i fuel1 -i owner -f name \
	&& rm global-power-plants.csv \
	&& git clone https://github.com/simonw/datasette.git \
	&& cd datasette && python setup.py bdist_wheel && cd .. \
	&& pip install datasette/dist/*.whl \
	&& pip install https://github.com/simonw/datasette-cluster-map/archive/size-max.zip \
	&& pip install datasette-vega \
	&& rm -rf datasette \
	&& datasette inspect global-power-plants.db --inspect-file inspect-data.json

EXPOSE 8001

CMD datasette serve global-power-plants.db --host 0.0.0.0 \
    --cors --port ${PORT:-8001} --inspect-file inspect-data.json -m metadata.json
