# AWS Lab: Web Server HA & AI Data Lake (AIO2025)

Tài liệu thực hành dựa trên giáo trình AI VIET NAM COURSE 2025. 

---

## 🟦 BUỔI 1: THỨ HAI (16/03) - ALB & EC2 AUTO SCALING GROUP
**Mục tiêu:** Triển khai hệ thống High Availability trên nhiều Availability Zones.

### 🖱 Các bước thao tác Console (Học thi CLF-C02)
1. **Security Groups:** - `d-sg-alb-aivn`: Mở port 80 (0.0.0.0/0).
   - `d-sg-websv-aivn`: Mở port 80 (Source: `d-sg-alb-aivn`).
2. **Launch Template:** Tạo `d-lt-webserver-template` (t3.micro, Amazon Linux 2023).
3. **Auto Scaling Group:** Tạo `d-asg-webserver-aivn` (Desired: 1, Min: 1, Max: 3).
4. **Load Balancer:** Tạo ALB `d-alb-webservers-aivn`, điều hướng vào Target Group `d-tg-webservers-aivn`.
5. **Scale out EC2:** Thực hiện stress test (`sudo stress -c 4`) để CPU vượt ngưỡng 50%.

---

## 🟩 BUỔI 2: THỨ NĂM (19/03) - BUILD AN AI DATA LAKE WITH S3
**Mục tiêu:** Thiết lập Object Storage và tự động hóa vòng đời dữ liệu.

### 🖱 Các bước thao tác Console (Học thi CLF-C02)
1. **S3 Bucket:** Tạo bucket `ai-data-lake-demo-vinh` (SSE-S3, Versioning Disable).
2. **Cấu trúc Data Lake:** Tạo các folder `raw`, `processed`, `training`, `models`, `logs`.
3. **Lifecycle Policy:** Thiết lập rule `ai-data-lifecycle`:
   - Chuyển sang **Standard-IA** sau 30 ngày.
   - Chuyển sang **Glacier Instant Retrieval** sau 90 ngày.
   - **Xóa** object (Expire) sau 365 ngày.

---

## 🚀 PHẦN TỰ LÀM THÊM: HOẠCH ĐỊNH BẰNG TERRAFORM
*Phần này mình tự viết code để hoạch định các bước cần thiết, không nằm trong yêu cầu giáo trình.*

**Nội dung hoạch định trong `main.tf`:**
* Khai báo chính xác các Security Group và Resource Name theo chuẩn AIO2025.
* Hoạch định luồng Traffic: User -> ALB SG -> ALB -> Web SG -> EC2.
* Hoạch định chính sách Scaling Target Tracking (CPU 50%).
* Hoạch định đầy đủ 3 giai đoạn của S3 Lifecycle Rule.
