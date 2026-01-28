FROM python:3.9-slim

# Cài đặt các gói hệ thống cần thiết (LaTeX và pdf2svg)
RUN apt-get update && apt-get install -y \
    texlive-latex-base \
    texlive-latex-extra \
    texlive-pictures \
    texlive-lang-vietnamese \
    texlive-fonts-recommended \
    pdf2svg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .
RUN pip install --no-cache-dir -r requirements.txt

# Port mặc định của Render
EXPOSE 10000

CMD ["python", "main.py"]
