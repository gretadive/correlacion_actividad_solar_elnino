{
  "nbformat": 4,
  "nbformat_minor": 0,
  "metadata": {
    "colab": {
      "provenance": [],
      "authorship_tag": "ABX9TyPjS/EfrU6oYIvhQKARZoeg",
      "include_colab_link": true
    },
    "kernelspec": {
      "name": "python3",
      "display_name": "Python 3"
    },
    "language_info": {
      "name": "python"
    }
  },
  "cells": [
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "view-in-github",
        "colab_type": "text"
      },
      "source": [
        "<a href=\"https://colab.research.google.com/github/gretadive/correlacion_actividad_solar_elnino/blob/main/05_limpieza_precipitacion_ERA5.ipynb\" target=\"_parent\"><img src=\"https://colab.research.google.com/assets/colab-badge.svg\" alt=\"Open In Colab\"/></a>"
      ]
    },
    {
      "cell_type": "code",
      "source": [
        "!pip install openpyxl"
      ],
      "metadata": {
        "colab": {
          "base_uri": "https://localhost:8080/"
        },
        "id": "_oTmfF2HKtQB",
        "outputId": "459cfb43-b268-4a16-f0f8-4afebe3073e5"
      },
      "execution_count": 8,
      "outputs": [
        {
          "output_type": "stream",
          "name": "stdout",
          "text": [
            "Requirement already satisfied: openpyxl in /usr/local/lib/python3.13/dist-packages (3.1.5)\n",
            "Requirement already satisfied: et-xmlfile in /usr/local/lib/python3.13/dist-packages (from openpyxl) (2.0.0)\n"
          ]
        }
      ]
    },
    {
      "cell_type": "code",
      "source": [
        "import xarray as xr\n",
        "import pandas as pd\n",
        "import numpy as np\n",
        "import matplotlib.pyplot as plt\n"
      ],
      "metadata": {
        "id": "61aFWCb0bwQJ"
      },
      "execution_count": 9,
      "outputs": []
    },
    {
      "cell_type": "code",
      "source": [
        "ruta = \"7666a0490891a08eeb53407c7d1c8235.nc\"\n",
        "\n",
        "ds = xr.open_dataset(ruta)\n",
        "\n",
        "print(ds)\n",
        "print(\"\\nInformación de la variable tp:\")\n",
        "print(ds[\"tp\"].attrs)"
      ],
      "metadata": {
        "colab": {
          "base_uri": "https://localhost:8080/"
        },
        "id": "pwO1tZ6Fbzt6",
        "outputId": "fe9d83d5-8f02-421d-d9bc-53491cd28292"
      },
      "execution_count": 10,
      "outputs": [
        {
          "output_type": "stream",
          "name": "stdout",
          "text": [
            "<xarray.Dataset> Size: 8MB\n",
            "Dimensions:     (valid_time: 920, latitude: 51, longitude: 41)\n",
            "Coordinates:\n",
            "  * valid_time  (valid_time) datetime64[ns] 7kB 1950-01-01 ... 2026-08-01\n",
            "  * latitude    (latitude) float64 408B -3.0 -3.1 -3.2 -3.3 ... -7.8 -7.9 -8.0\n",
            "  * longitude   (longitude) float64 328B -82.0 -81.9 -81.8 ... -78.2 -78.1 -78.0\n",
            "    number      int64 8B ...\n",
            "    expver      (valid_time) <U4 15kB ...\n",
            "Data variables:\n",
            "    tp          (valid_time, latitude, longitude) float32 8MB ...\n",
            "Attributes:\n",
            "    GRIB_centre:             ecmf\n",
            "    GRIB_centreDescription:  European Centre for Medium-Range Weather Forecasts\n",
            "    GRIB_subCentre:          0\n",
            "    Conventions:             CF-1.7\n",
            "    institution:             European Centre for Medium-Range Weather Forecasts\n",
            "    history:                 2026-09-19T00:43 GRIB to CDM+CF via cfgrib-0.9.1...\n",
            "\n",
            "Información de la variable tp:\n",
            "{'GRIB_paramId': np.int64(228), 'GRIB_dataType': 'fc', 'GRIB_numberOfPoints': np.int64(2091), 'GRIB_typeOfLevel': 'surface', 'GRIB_stepUnits': np.int64(1), 'GRIB_gridType': 'regular_ll', 'GRIB_uvRelativeToGrid': np.int64(0), 'GRIB_NV': np.int64(0), 'GRIB_Nx': np.int64(41), 'GRIB_Ny': np.int64(51), 'GRIB_cfName': 'unknown', 'GRIB_cfVarName': 'tp', 'GRIB_gridDefinitionDescription': 'Latitude/Longitude Grid', 'GRIB_iDirectionIncrementInDegrees': np.float64(0.1), 'GRIB_iScansNegatively': np.int64(0), 'GRIB_jDirectionIncrementInDegrees': np.float64(0.1), 'GRIB_jPointsAreConsecutive': np.int64(0), 'GRIB_jScansPositively': np.int64(0), 'GRIB_latitudeOfFirstGridPointInDegrees': np.float64(-3.0), 'GRIB_latitudeOfLastGridPointInDegrees': np.float64(-8.0), 'GRIB_longitudeOfFirstGridPointInDegrees': np.float64(-82.0), 'GRIB_longitudeOfLastGridPointInDegrees': np.float64(-78.0), 'GRIB_missingValue': np.float64(3.4028234663852886e+38), 'GRIB_name': 'Total precipitation', 'GRIB_shortName': 'tp', 'GRIB_totalNumber': np.int64(0), 'GRIB_units': 'm', 'long_name': 'Total precipitation', 'units': 'm', 'standard_name': 'unknown', 'GRIB_surface': np.float64(0.0)}\n"
          ]
        }
      ]
    },
    {
      "cell_type": "code",
      "source": [
        "# Pesos según latitud\n",
        "pesos = np.cos(np.deg2rad(ds[\"latitude\"]))\n",
        "\n",
        "# Promedio espacial ponderado\n",
        "precip = ds[\"tp\"].weighted(pesos).mean(\n",
        "    dim=[\"latitude\", \"longitude\"]\n",
        ")\n",
        "\n",
        "# Convertir a DataFrame\n",
        "df = precip.to_dataframe().reset_index()\n",
        "\n",
        "df.head()"
      ],
      "metadata": {
        "colab": {
          "base_uri": "https://localhost:8080/",
          "height": 206
        },
        "id": "LE7gAazUb6DJ",
        "outputId": "57f8384a-a91c-4ea3-a962-0bdb720249e6"
      },
      "execution_count": 11,
      "outputs": [
        {
          "output_type": "execute_result",
          "data": {
            "text/plain": [
              "  valid_time  number expver        tp\n",
              "0 1950-01-01       0   0001  0.005010\n",
              "1 1950-02-01       0   0001  0.005891\n",
              "2 1950-03-01       0   0001  0.005103\n",
              "3 1950-04-01       0   0001  0.007390\n",
              "4 1950-05-01       0   0001  0.003994"
            ],
            "text/html": [
              "\n",
              "  <div id=\"df-4e8b692e-8ad4-4b5c-87e6-247a93b3a794\" class=\"colab-df-container\">\n",
              "    <div>\n",
              "<style scoped>\n",
              "    .dataframe tbody tr th:only-of-type {\n",
              "        vertical-align: middle;\n",
              "    }\n",
              "\n",
              "    .dataframe tbody tr th {\n",
              "        vertical-align: top;\n",
              "    }\n",
              "\n",
              "    .dataframe thead th {\n",
              "        text-align: right;\n",
              "    }\n",
              "</style>\n",
              "<table border=\"1\" class=\"dataframe\">\n",
              "  <thead>\n",
              "    <tr style=\"text-align: right;\">\n",
              "      <th></th>\n",
              "      <th>valid_time</th>\n",
              "      <th>number</th>\n",
              "      <th>expver</th>\n",
              "      <th>tp</th>\n",
              "    </tr>\n",
              "  </thead>\n",
              "  <tbody>\n",
              "    <tr>\n",
              "      <th>0</th>\n",
              "      <td>1950-01-01</td>\n",
              "      <td>0</td>\n",
              "      <td>0001</td>\n",
              "      <td>0.005010</td>\n",
              "    </tr>\n",
              "    <tr>\n",
              "      <th>1</th>\n",
              "      <td>1950-02-01</td>\n",
              "      <td>0</td>\n",
              "      <td>0001</td>\n",
              "      <td>0.005891</td>\n",
              "    </tr>\n",
              "    <tr>\n",
              "      <th>2</th>\n",
              "      <td>1950-03-01</td>\n",
              "      <td>0</td>\n",
              "      <td>0001</td>\n",
              "      <td>0.005103</td>\n",
              "    </tr>\n",
              "    <tr>\n",
              "      <th>3</th>\n",
              "      <td>1950-04-01</td>\n",
              "      <td>0</td>\n",
              "      <td>0001</td>\n",
              "      <td>0.007390</td>\n",
              "    </tr>\n",
              "    <tr>\n",
              "      <th>4</th>\n",
              "      <td>1950-05-01</td>\n",
              "      <td>0</td>\n",
              "      <td>0001</td>\n",
              "      <td>0.003994</td>\n",
              "    </tr>\n",
              "  </tbody>\n",
              "</table>\n",
              "</div>\n",
              "    <div class=\"colab-df-buttons\">\n",
              "\n",
              "  <div class=\"colab-df-container\">\n",
              "    <button class=\"colab-df-convert\" onclick=\"convertToInteractive('df-4e8b692e-8ad4-4b5c-87e6-247a93b3a794')\"\n",
              "            title=\"Convert this dataframe to an interactive table.\"\n",
              "            style=\"display:none;\">\n",
              "\n",
              "  <svg xmlns=\"http://www.w3.org/2000/svg\" height=\"24px\" viewBox=\"0 -960 960 960\">\n",
              "    <path d=\"M120-120v-720h720v720H120Zm60-500h600v-160H180v160Zm220 220h160v-160H400v160Zm0 220h160v-160H400v160ZM180-400h160v-160H180v160Zm440 0h160v-160H620v160ZM180-180h160v-160H180v160Zm440 0h160v-160H620v160Z\"/>\n",
              "  </svg>\n",
              "    </button>\n",
              "\n",
              "  <style>\n",
              "    .colab-df-container {\n",
              "      display:flex;\n",
              "      gap: 12px;\n",
              "    }\n",
              "\n",
              "    .colab-df-convert {\n",
              "      background-color: #E8F0FE;\n",
              "      border: none;\n",
              "      border-radius: 50%;\n",
              "      cursor: pointer;\n",
              "      display: none;\n",
              "      fill: #1967D2;\n",
              "      height: 32px;\n",
              "      padding: 0 0 0 0;\n",
              "      width: 32px;\n",
              "    }\n",
              "\n",
              "    .colab-df-convert:hover {\n",
              "      background-color: #E2EBFA;\n",
              "      box-shadow: 0px 1px 2px rgba(60, 64, 67, 0.3), 0px 1px 3px 1px rgba(60, 64, 67, 0.15);\n",
              "      fill: #174EA6;\n",
              "    }\n",
              "\n",
              "    .colab-df-buttons div {\n",
              "      margin-bottom: 4px;\n",
              "    }\n",
              "\n",
              "    [theme=dark] .colab-df-convert {\n",
              "      background-color: #3B4455;\n",
              "      fill: #D2E3FC;\n",
              "    }\n",
              "\n",
              "    [theme=dark] .colab-df-convert:hover {\n",
              "      background-color: #434B5C;\n",
              "      box-shadow: 0px 1px 3px 1px rgba(0, 0, 0, 0.15);\n",
              "      filter: drop-shadow(0px 1px 2px rgba(0, 0, 0, 0.3));\n",
              "      fill: #FFFFFF;\n",
              "    }\n",
              "  </style>\n",
              "\n",
              "    <script>\n",
              "      const buttonEl =\n",
              "        document.querySelector('#df-4e8b692e-8ad4-4b5c-87e6-247a93b3a794 button.colab-df-convert');\n",
              "      buttonEl.style.display =\n",
              "        google.colab.kernel.accessAllowed ? 'block' : 'none';\n",
              "\n",
              "      async function convertToInteractive(key) {\n",
              "        const element = document.querySelector('#df-4e8b692e-8ad4-4b5c-87e6-247a93b3a794');\n",
              "        const dataTable =\n",
              "          await google.colab.kernel.invokeFunction('convertToInteractive',\n",
              "                                                    [key], {});\n",
              "        if (!dataTable) return;\n",
              "\n",
              "        const docLinkHtml = 'Like what you see? Visit the ' +\n",
              "          '<a target=\"_blank\" href=https://colab.research.google.com/notebooks/data_table.ipynb>data table notebook</a>'\n",
              "          + ' to learn more about interactive tables.';\n",
              "        element.innerHTML = '';\n",
              "        dataTable['output_type'] = 'display_data';\n",
              "        await google.colab.output.renderOutput(dataTable, element);\n",
              "        const docLink = document.createElement('div');\n",
              "        docLink.innerHTML = docLinkHtml;\n",
              "        element.appendChild(docLink);\n",
              "      }\n",
              "    </script>\n",
              "  </div>\n",
              "\n",
              "\n",
              "    </div>\n",
              "  </div>\n"
            ],
            "application/vnd.google.colaboratory.intrinsic+json": {
              "type": "dataframe",
              "variable_name": "df",
              "summary": "{\n  \"name\": \"df\",\n  \"rows\": 920,\n  \"fields\": [\n    {\n      \"column\": \"valid_time\",\n      \"properties\": {\n        \"dtype\": \"date\",\n        \"min\": \"1950-01-01 00:00:00\",\n        \"max\": \"2026-08-01 00:00:00\",\n        \"num_unique_values\": 920,\n        \"samples\": [\n          \"1976-08-01 00:00:00\",\n          \"1981-06-01 00:00:00\",\n          \"1994-11-01 00:00:00\"\n        ],\n        \"semantic_type\": \"\",\n        \"description\": \"\"\n      }\n    },\n    {\n      \"column\": \"number\",\n      \"properties\": {\n        \"dtype\": \"number\",\n        \"std\": 0,\n        \"min\": 0,\n        \"max\": 0,\n        \"num_unique_values\": 1,\n        \"samples\": [\n          0\n        ],\n        \"semantic_type\": \"\",\n        \"description\": \"\"\n      }\n    },\n    {\n      \"column\": \"expver\",\n      \"properties\": {\n        \"dtype\": \"category\",\n        \"num_unique_values\": 2,\n        \"samples\": [\n          \"0005\"\n        ],\n        \"semantic_type\": \"\",\n        \"description\": \"\"\n      }\n    },\n    {\n      \"column\": \"tp\",\n      \"properties\": {\n        \"dtype\": \"number\",\n        \"std\": 0.002643526018244821,\n        \"min\": 0.0005759955351756663,\n        \"max\": 0.019241357389654296,\n        \"num_unique_values\": 920,\n        \"samples\": [\n          0.0022117541681653005\n        ],\n        \"semantic_type\": \"\",\n        \"description\": \"\"\n      }\n    }\n  ]\n}"
            }
          },
          "metadata": {},
          "execution_count": 11
        }
      ]
    },
    {
      "cell_type": "code",
      "source": [
        "# Convertir fecha\n",
        "df[\"valid_time\"] = pd.to_datetime(df[\"valid_time\"])\n",
        "\n",
        "# Año, mes y número de días\n",
        "df[\"año\"] = df[\"valid_time\"].dt.year\n",
        "df[\"mes\"] = df[\"valid_time\"].dt.month\n",
        "df[\"dias_mes\"] = df[\"valid_time\"].dt.days_in_month\n",
        "\n",
        "# ERA5: m/día → mm/mes\n",
        "df[\"precipitacion_mm\"] = (\n",
        "    df[\"tp\"] * 1000 * df[\"dias_mes\"]\n",
        ")\n",
        "\n",
        "# Fecha mensual\n",
        "df[\"fecha\"] = pd.to_datetime(\n",
        "    dict(\n",
        "        year=df[\"año\"],\n",
        "        month=df[\"mes\"],\n",
        "        day=1\n",
        "    )\n",
        ")\n",
        "\n",
        "# Dataset final\n",
        "df_precipitacion = df[\n",
        "    [\"fecha\", \"año\", \"mes\", \"precipitacion_mm\"]\n",
        "].copy()\n",
        "\n",
        "df_precipitacion.head()"
      ],
      "metadata": {
        "colab": {
          "base_uri": "https://localhost:8080/",
          "height": 206
        },
        "id": "JB6RV0j5ck3N",
        "outputId": "4d8962d8-3c3d-4cee-c829-53c0218d7fc7"
      },
      "execution_count": 12,
      "outputs": [
        {
          "output_type": "execute_result",
          "data": {
            "text/plain": [
              "       fecha   año  mes  precipitacion_mm\n",
              "0 1950-01-01  1950    1        155.309817\n",
              "1 1950-02-01  1950    2        164.955825\n",
              "2 1950-03-01  1950    3        158.180623\n",
              "3 1950-04-01  1950    4        221.687990\n",
              "4 1950-05-01  1950    5        123.802819"
            ],
            "text/html": [
              "\n",
              "  <div id=\"df-04a37a75-597d-4287-9fce-f7c47aa4bd49\" class=\"colab-df-container\">\n",
              "    <div>\n",
              "<style scoped>\n",
              "    .dataframe tbody tr th:only-of-type {\n",
              "        vertical-align: middle;\n",
              "    }\n",
              "\n",
              "    .dataframe tbody tr th {\n",
              "        vertical-align: top;\n",
              "    }\n",
              "\n",
              "    .dataframe thead th {\n",
              "        text-align: right;\n",
              "    }\n",
              "</style>\n",
              "<table border=\"1\" class=\"dataframe\">\n",
              "  <thead>\n",
              "    <tr style=\"text-align: right;\">\n",
              "      <th></th>\n",
              "      <th>fecha</th>\n",
              "      <th>año</th>\n",
              "      <th>mes</th>\n",
              "      <th>precipitacion_mm</th>\n",
              "    </tr>\n",
              "  </thead>\n",
              "  <tbody>\n",
              "    <tr>\n",
              "      <th>0</th>\n",
              "      <td>1950-01-01</td>\n",
              "      <td>1950</td>\n",
              "      <td>1</td>\n",
              "      <td>155.309817</td>\n",
              "    </tr>\n",
              "    <tr>\n",
              "      <th>1</th>\n",
              "      <td>1950-02-01</td>\n",
              "      <td>1950</td>\n",
              "      <td>2</td>\n",
              "      <td>164.955825</td>\n",
              "    </tr>\n",
              "    <tr>\n",
              "      <th>2</th>\n",
              "      <td>1950-03-01</td>\n",
              "      <td>1950</td>\n",
              "      <td>3</td>\n",
              "      <td>158.180623</td>\n",
              "    </tr>\n",
              "    <tr>\n",
              "      <th>3</th>\n",
              "      <td>1950-04-01</td>\n",
              "      <td>1950</td>\n",
              "      <td>4</td>\n",
              "      <td>221.687990</td>\n",
              "    </tr>\n",
              "    <tr>\n",
              "      <th>4</th>\n",
              "      <td>1950-05-01</td>\n",
              "      <td>1950</td>\n",
              "      <td>5</td>\n",
              "      <td>123.802819</td>\n",
              "    </tr>\n",
              "  </tbody>\n",
              "</table>\n",
              "</div>\n",
              "    <div class=\"colab-df-buttons\">\n",
              "\n",
              "  <div class=\"colab-df-container\">\n",
              "    <button class=\"colab-df-convert\" onclick=\"convertToInteractive('df-04a37a75-597d-4287-9fce-f7c47aa4bd49')\"\n",
              "            title=\"Convert this dataframe to an interactive table.\"\n",
              "            style=\"display:none;\">\n",
              "\n",
              "  <svg xmlns=\"http://www.w3.org/2000/svg\" height=\"24px\" viewBox=\"0 -960 960 960\">\n",
              "    <path d=\"M120-120v-720h720v720H120Zm60-500h600v-160H180v160Zm220 220h160v-160H400v160Zm0 220h160v-160H400v160ZM180-400h160v-160H180v160Zm440 0h160v-160H620v160ZM180-180h160v-160H180v160Zm440 0h160v-160H620v160Z\"/>\n",
              "  </svg>\n",
              "    </button>\n",
              "\n",
              "  <style>\n",
              "    .colab-df-container {\n",
              "      display:flex;\n",
              "      gap: 12px;\n",
              "    }\n",
              "\n",
              "    .colab-df-convert {\n",
              "      background-color: #E8F0FE;\n",
              "      border: none;\n",
              "      border-radius: 50%;\n",
              "      cursor: pointer;\n",
              "      display: none;\n",
              "      fill: #1967D2;\n",
              "      height: 32px;\n",
              "      padding: 0 0 0 0;\n",
              "      width: 32px;\n",
              "    }\n",
              "\n",
              "    .colab-df-convert:hover {\n",
              "      background-color: #E2EBFA;\n",
              "      box-shadow: 0px 1px 2px rgba(60, 64, 67, 0.3), 0px 1px 3px 1px rgba(60, 64, 67, 0.15);\n",
              "      fill: #174EA6;\n",
              "    }\n",
              "\n",
              "    .colab-df-buttons div {\n",
              "      margin-bottom: 4px;\n",
              "    }\n",
              "\n",
              "    [theme=dark] .colab-df-convert {\n",
              "      background-color: #3B4455;\n",
              "      fill: #D2E3FC;\n",
              "    }\n",
              "\n",
              "    [theme=dark] .colab-df-convert:hover {\n",
              "      background-color: #434B5C;\n",
              "      box-shadow: 0px 1px 3px 1px rgba(0, 0, 0, 0.15);\n",
              "      filter: drop-shadow(0px 1px 2px rgba(0, 0, 0, 0.3));\n",
              "      fill: #FFFFFF;\n",
              "    }\n",
              "  </style>\n",
              "\n",
              "    <script>\n",
              "      const buttonEl =\n",
              "        document.querySelector('#df-04a37a75-597d-4287-9fce-f7c47aa4bd49 button.colab-df-convert');\n",
              "      buttonEl.style.display =\n",
              "        google.colab.kernel.accessAllowed ? 'block' : 'none';\n",
              "\n",
              "      async function convertToInteractive(key) {\n",
              "        const element = document.querySelector('#df-04a37a75-597d-4287-9fce-f7c47aa4bd49');\n",
              "        const dataTable =\n",
              "          await google.colab.kernel.invokeFunction('convertToInteractive',\n",
              "                                                    [key], {});\n",
              "        if (!dataTable) return;\n",
              "\n",
              "        const docLinkHtml = 'Like what you see? Visit the ' +\n",
              "          '<a target=\"_blank\" href=https://colab.research.google.com/notebooks/data_table.ipynb>data table notebook</a>'\n",
              "          + ' to learn more about interactive tables.';\n",
              "        element.innerHTML = '';\n",
              "        dataTable['output_type'] = 'display_data';\n",
              "        await google.colab.output.renderOutput(dataTable, element);\n",
              "        const docLink = document.createElement('div');\n",
              "        docLink.innerHTML = docLinkHtml;\n",
              "        element.appendChild(docLink);\n",
              "      }\n",
              "    </script>\n",
              "  </div>\n",
              "\n",
              "\n",
              "    </div>\n",
              "  </div>\n"
            ],
            "application/vnd.google.colaboratory.intrinsic+json": {
              "type": "dataframe",
              "variable_name": "df_precipitacion",
              "summary": "{\n  \"name\": \"df_precipitacion\",\n  \"rows\": 920,\n  \"fields\": [\n    {\n      \"column\": \"fecha\",\n      \"properties\": {\n        \"dtype\": \"date\",\n        \"min\": \"1950-01-01 00:00:00\",\n        \"max\": \"2026-08-01 00:00:00\",\n        \"num_unique_values\": 920,\n        \"samples\": [\n          \"1976-08-01 00:00:00\",\n          \"1981-06-01 00:00:00\",\n          \"1994-11-01 00:00:00\"\n        ],\n        \"semantic_type\": \"\",\n        \"description\": \"\"\n      }\n    },\n    {\n      \"column\": \"a\\u00f1o\",\n      \"properties\": {\n        \"dtype\": \"int32\",\n        \"num_unique_values\": 77,\n        \"samples\": [\n          1954,\n          1985,\n          1960\n        ],\n        \"semantic_type\": \"\",\n        \"description\": \"\"\n      }\n    },\n    {\n      \"column\": \"mes\",\n      \"properties\": {\n        \"dtype\": \"int32\",\n        \"num_unique_values\": 12,\n        \"samples\": [\n          11,\n          10,\n          1\n        ],\n        \"semantic_type\": \"\",\n        \"description\": \"\"\n      }\n    },\n    {\n      \"column\": \"precipitacion_mm\",\n      \"properties\": {\n        \"dtype\": \"number\",\n        \"std\": 78.93202466009207,\n        \"min\": 17.855861590445656,\n        \"max\": 596.4820790792833,\n        \"num_unique_values\": 920,\n        \"samples\": [\n          68.56437921312431,\n          101.17529595359626,\n          131.19813108519514\n        ],\n        \"semantic_type\": \"\",\n        \"description\": \"\"\n      }\n    }\n  ]\n}"
            }
          },
          "metadata": {},
          "execution_count": 12
        }
      ]
    },
    {
      "cell_type": "code",
      "source": [
        "print(\"Total de registros:\", len(df_precipitacion))\n",
        "print(\n",
        "    \"Periodo:\",\n",
        "    df_precipitacion[\"fecha\"].min(),\n",
        "    \"a\",\n",
        "    df_precipitacion[\"fecha\"].max()\n",
        ")\n",
        "\n",
        "print(\"\\nValores faltantes:\")\n",
        "print(df_precipitacion.isnull().sum())\n",
        "\n",
        "print(\n",
        "    \"\\nFechas duplicadas:\",\n",
        "    df_precipitacion[\"fecha\"].duplicated().sum()\n",
        ")\n",
        "\n",
        "print(\"\\nEstadísticas:\")\n",
        "print(\n",
        "    df_precipitacion[\"precipitacion_mm\"].describe()\n",
        ")"
      ],
      "metadata": {
        "colab": {
          "base_uri": "https://localhost:8080/"
        },
        "id": "0eOh_lG1cut1",
        "outputId": "08d1b465-17e7-49b7-f515-ab2c5feb9ed9"
      },
      "execution_count": 13,
      "outputs": [
        {
          "output_type": "stream",
          "name": "stdout",
          "text": [
            "Total de registros: 920\n",
            "Periodo: 1950-01-01 00:00:00 a 2026-08-01 00:00:00\n",
            "\n",
            "Valores faltantes:\n",
            "fecha               0\n",
            "año                 0\n",
            "mes                 0\n",
            "precipitacion_mm    0\n",
            "dtype: int64\n",
            "\n",
            "Fechas duplicadas: 0\n",
            "\n",
            "Estadísticas:\n",
            "count    920.000000\n",
            "mean     140.564987\n",
            "std       78.932025\n",
            "min       17.855862\n",
            "25%       79.553342\n",
            "50%      123.802076\n",
            "75%      180.193366\n",
            "max      596.482079\n",
            "Name: precipitacion_mm, dtype: float64\n"
          ]
        }
      ]
    },
    {
      "cell_type": "code",
      "source": [
        "fechas_esperadas = pd.date_range(\n",
        "    start=df_precipitacion[\"fecha\"].min(),\n",
        "    end=df_precipitacion[\"fecha\"].max(),\n",
        "    freq=\"MS\"\n",
        ")\n",
        "\n",
        "faltantes = fechas_esperadas.difference(\n",
        "    df_precipitacion[\"fecha\"]\n",
        ")\n",
        "\n",
        "print(\"Meses faltantes:\", len(faltantes))\n",
        "\n",
        "if len(faltantes) == 0:\n",
        "    print(\"✅ Serie mensual continua\")\n",
        "else:\n",
        "    print(faltantes)"
      ],
      "metadata": {
        "colab": {
          "base_uri": "https://localhost:8080/"
        },
        "id": "MCViXUQ0c0s9",
        "outputId": "c9982c84-e33e-4765-c370-a50b59935fc8"
      },
      "execution_count": 14,
      "outputs": [
        {
          "output_type": "stream",
          "name": "stdout",
          "text": [
            "Meses faltantes: 0\n",
            "✅ Serie mensual continua\n"
          ]
        }
      ]
    },
    {
      "cell_type": "code",
      "source": [
        "nombre_archivo = \"precipitacion.ERA5_procesado.csv\"\n",
        "\n",
        "df_precipitacion.to_csv(\n",
        "    nombre_archivo,\n",
        "    index=False\n",
        ")\n",
        "\n",
        "print(\"✅ Archivo creado:\", nombre_archivo)"
      ],
      "metadata": {
        "colab": {
          "base_uri": "https://localhost:8080/"
        },
        "id": "akt8SJkKc4v4",
        "outputId": "5d655f47-1107-4929-824a-bd58272b92cf"
      },
      "execution_count": 15,
      "outputs": [
        {
          "output_type": "stream",
          "name": "stdout",
          "text": [
            "✅ Archivo creado: precipitacion.ERA5_procesado.csv\n"
          ]
        }
      ]
    },
    {
      "cell_type": "code",
      "source": [
        "from google.colab import files\n",
        "\n",
        "files.download(\"precipitacion.ERA5_procesado.csv\")"
      ],
      "metadata": {
        "colab": {
          "base_uri": "https://localhost:8080/",
          "height": 17
        },
        "id": "4W1OIphLdAtw",
        "outputId": "a3ccde01-b036-4456-e242-1fabeaef77b4"
      },
      "execution_count": 16,
      "outputs": [
        {
          "output_type": "display_data",
          "data": {
            "text/plain": [
              "<IPython.core.display.Javascript object>"
            ],
            "application/javascript": [
              "\n",
              "    async function download(id, filename, size) {\n",
              "      if (!google.colab.kernel.accessAllowed) {\n",
              "        return;\n",
              "      }\n",
              "      const div = document.createElement('div');\n",
              "      const label = document.createElement('label');\n",
              "      label.textContent = `Downloading \"${filename}\": `;\n",
              "      div.appendChild(label);\n",
              "      const progress = document.createElement('progress');\n",
              "      progress.max = size;\n",
              "      div.appendChild(progress);\n",
              "      document.body.appendChild(div);\n",
              "\n",
              "      const buffers = [];\n",
              "      let downloaded = 0;\n",
              "\n",
              "      const channel = await google.colab.kernel.comms.open(id);\n",
              "      // Send a message to notify the kernel that we're ready.\n",
              "      channel.send({})\n",
              "\n",
              "      for await (const message of channel.messages) {\n",
              "        // Send a message to notify the kernel that we're ready.\n",
              "        channel.send({})\n",
              "        if (message.buffers) {\n",
              "          for (const buffer of message.buffers) {\n",
              "            buffers.push(buffer);\n",
              "            downloaded += buffer.byteLength;\n",
              "            progress.value = downloaded;\n",
              "          }\n",
              "        }\n",
              "      }\n",
              "      const blob = new Blob(buffers, {type: 'application/binary'});\n",
              "      const a = document.createElement('a');\n",
              "      a.href = window.URL.createObjectURL(blob);\n",
              "      a.download = filename;\n",
              "      div.appendChild(a);\n",
              "      a.click();\n",
              "      div.remove();\n",
              "    }\n",
              "  "
            ]
          },
          "metadata": {}
        },
        {
          "output_type": "display_data",
          "data": {
            "text/plain": [
              "<IPython.core.display.Javascript object>"
            ],
            "application/javascript": [
              "download(\"download_f8701546-c322-45d2-a7de-cc15e76b5d30\", \"precipitacion.ERA5_procesado.csv\", 33753)"
            ]
          },
          "metadata": {}
        }
      ]
    }
  ]
}
