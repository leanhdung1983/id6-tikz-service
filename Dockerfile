# 1. QUAN TRỌNG: Phải dùng image Node.js (dựa trên Debian slim)
FROM node:20-slim

# 2. Thiết lập biến môi trường để apt không hỏi confirm
ENV DEBIAN_FRONTEND=noninteractive

# 3. Thiết lập thư mục làm việc
WORKDIR /app

# 4. CÀI ĐẶT TEXLIVE VÀ CÁC GÓI CẦN THIẾT
# Dùng base node:slim vẫn có apt-get nên đoạn này hoạt động tốt
RUN apt-get update && apt-get install -y --no-install-recommends \
    texlive-latex-base \
    texlive-latex-extra \
    texlive-pictures \
    texlive-lang-vietnamese \
    texlive-fonts-recommended \
    pdf2svg \
    ghostscript \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 5. Copy package.json và cài đặt dependencies
COPY package*.json ./
RUN npm install --production

# 6. Copy toàn bộ mã nguồn
COPY . .

# 7. Expose port
EXPOSE 3000

# 8. Chạy ứng dụng
CMD ["node", "index.js"]
