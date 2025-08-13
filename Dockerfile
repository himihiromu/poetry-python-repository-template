# pythonパッケージのビルド
FROM python:3.12-slim as build

# 作業ディレクトリの設定
WORKDIR /app

# セキュリティ対策のパッケージバージョンアップ
RUN apt-get update && apt-get install -y curl \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# poetryのインストール
RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH="/root/.local/bin:$PATH"


# poetry関連ファイルのコピー
COPY pyproject.toml .
COPY poetry.lock .
 
# パッケージインストール
RUN poetry config virtualenvs.create false && \
  poetry install && \
  rm -rf ~/.cache


# 実行環境
FROM python:3.12-slim as prod

# 作業ディレクトリの設定
WORKDIR /app

ENV PYTHONPATH=/app

# DBデータを格納するフォルダ作成
RUN mkdir data

# 一応セキュリティ対策のパッケージバージョンアップ
RUN apt-get update && apt-get install \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# 必要なパッケージのインストール
COPY --from=build /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages

# 環境変数ファイルをコピー
COPY .env .

# 作業ディレクトリ配下へコピー
COPY src/ .

# アプリケーションの実行
CMD ["python", "index.py"]

# test用実行環境
FROM build as test

# 作業ディレクトリの設定
WORKDIR /app

ENV PYTHONPATH=/app/src
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:/root/.local/bin:$PATH"

# ファイルをコンテナ内にコピー
COPY ./src ./src
COPY ./test ./test
COPY ./tox.ini .

# アプリケーションの実行
CMD ["poetry", "run", "tox"]
