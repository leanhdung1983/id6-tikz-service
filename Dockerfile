# 1. Sử dụng image 'slim' để nhẹ hơn nhưng vẫn hỗ trợ tốt apt-get
FROM python:3.9-slim

# 2. Thiết lập biến môi trường để apt không hỏi confirm (non-interactive)
ENV DEBIAN_FRONTEND=noninteractive

# 3. Thiết lập thư mục làm việc
WORKDIR /app

# 4. CÀI ĐẶT TEXLIVE VÀ CÁC GÓI CẦN THIẾT
# - Sử dụng --no-install-recommends để KHÔNG cài các gói rác (docs, manpages...) -> Giảm dung lượng và thời gian build cực nhiều
# - Thêm ghostscript (thường cần cho pdf2svg xử lý)
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

# 5. Copy package.json và cài đặt dependencies của Node
COPY package*.json ./
RUN npm install --production

# 6. Copy toàn bộ mã nguồn vào
COPY . .

# 7. Expose port (Render thường dùng PORT env, nhưng cứ khai báo 3000 làm mặc định)
EXPOSE 3000

# 8. Chạy ứng dụng
CMD ["node", "index.js"] 
# (Lưu ý: đổi 'index.js' thành file chạy chính của bạn, ví dụ: src/app.js)
