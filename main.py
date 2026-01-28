import os
import subprocess
import uuid
import base64
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI()

class TikzRequest(BaseModel):
    code: str

# Mẫu LaTeX chuẩn để bọc mã TikZ
LATEX_TEMPLATE = r"""
\documentclass[tikz,border=2pt]{standalone}
\usepackage[utf8]{vietnam}
\usepackage{amsmath,amssymb}
\usepackage{amsfonts}
\usepackage{pgfplots}
\pgfplotsset{compat=1.18}
\begin{document}
%s
\end{document}
"""

@app.post("/render")
async def render_tikz(request: TikzRequest):
    job_id = str(uuid.uuid4())
    tex_file = f"{job_id}.tex"
    pdf_file = f"{job_id}.pdf"
    svg_file = f"{job_id}.svg"

    # Ghi mã LaTeX ra file
    with open(tex_file, "w", encoding="utf-8") as f:
        f.write(LATEX_TEMPLATE % request.code)

    try:
        # 1. Biên dịch LaTeX sang PDF
        subprocess.run(["pdflatex", "-interaction=nonstopmode", tex_file], 
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=15)
        
        if not os.path.exists(pdf_file):
            raise HTTPException(status_code=400, detail="Lỗi biên dịch LaTeX. Kiểm tra cú pháp TikZ.")

        # 2. Chuyển PDF sang SVG
        subprocess.run(["pdf2svg", pdf_file, svg_file], timeout=5)

        # 3. Đọc SVG và chuyển sang Base64
        with open(svg_file, "rb") as f:
            svg_data = f.read()
            base64_svg = base64.b64encode(svg_data).decode("utf-8")
            return {"url": f"data:image/svg+xml;base64,{base64_svg}"}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
    finally:
        # Dọn dẹp file tạm
        for ext in ["tex", "pdf", "svg", "aux", "log"]:
            f = f"{job_id}.{ext}"
            if os.path.exists(f): os.remove(f)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=int(os.environ.get("PORT", 8000)))
