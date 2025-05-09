CREATE DATABASE QuanLyGiaoHuong;
GO
USE QuanLyGiaoHuong;

#Tạo bảng 
CREATE TABLE MUABIEUDIEN (
    NGAYBD DATE PRIMARY KEY
);

CREATE TABLE NHACTRUONG (
    MANHACTRUONG INT PRIMARY KEY,
    TENNHACTRUONG NVARCHAR(100)
);

CREATE TABLE CHUONGTRINH (
    SOCT INT PRIMARY KEY,
    NGAYBDCT DATE,
    GIOBD TIME,
    NGAYBD DATE,
    MANHACTRUONG INT,
    FOREIGN KEY (NGAYBD) REFERENCES MUABIEUDIEN(NGAYBD),
    FOREIGN KEY (MANHACTRUONG) REFERENCES NHACTRUONG(MANHACTRUONG)
);

CREATE TABLE TACPHAM (
    TENTP NVARCHAR(100),
    TENTG NVARCHAR(100),
    PRIMARY KEY (TENTP, TENTG)
);

CREATE TABLE PHANDOAN (
    TENTP NVARCHAR(100),
    TENTG NVARCHAR(100),
    SOPD INT,
    TENPD NVARCHAR(100),
    PRIMARY KEY (TENTP, TENTG, SOPD),
    FOREIGN KEY (TENTP, TENTG) REFERENCES TACPHAM(TENTP, TENTG)
);

CREATE TABLE CT_TACPHAM (
    SOCT INT,
    TENTP NVARCHAR(100),
    TENTG NVARCHAR(100),
    PRIMARY KEY (SOCT, TENTP, TENTG),
    FOREIGN KEY (SOCT) REFERENCES CHUONGTRINH(SOCT),
    FOREIGN KEY (TENTP, TENTG) REFERENCES TACPHAM(TENTP, TENTG)
);

CREATE TABLE NGUOIHATSOLO (
    MASOLO INT PRIMARY KEY,
    TENSOLO NVARCHAR(100),
    NGAYCUOIHAT DATE
);

CREATE TABLE SOLO_TACPHAM_CT (
    MASOLO INT,
    SOCT INT,
    TENTP NVARCHAR(100),
    TENTG NVARCHAR(100),
    PRIMARY KEY (MASOLO, SOCT, TENTP, TENTG),
    FOREIGN KEY (MASOLO) REFERENCES NGUOIHATSOLO(MASOLO),
    FOREIGN KEY (SOCT, TENTP, TENTG) REFERENCES CT_TACPHAM(SOCT, TENTP, TENTG)
);

#Nhập dữ liệu mẫu 
-- MUABIEUDIEN
INSERT INTO MUABIEUDIEN VALUES ('2025-05-01');
INSERT INTO MUABIEUDIEN VALUES ('2025-06-15');

-- NHACTRUONG
INSERT INTO NHACTRUONG VALUES (1, N'Nhạc trưởng A');
INSERT INTO NHACTRUONG VALUES (2, N'Nhạc trưởng B');

-- CHUONGTRINH
INSERT INTO CHUONGTRINH VALUES (101, '2025-05-01', '19:00', '2025-05-01', 1);
INSERT INTO CHUONGTRINH VALUES (102, '2025-06-15', '20:00', '2025-06-15', 2);

-- TACPHAM
INSERT INTO TACPHAM VALUES (N'Bản giao hưởng số 5', N'Beethoven');
INSERT INTO TACPHAM VALUES (N'Hồ Thiên Nga', N'Tchaikovsky');

-- PHANDOAN
INSERT INTO PHANDOAN VALUES (N'Bản giao hưởng số 5', N'Beethoven', 1, N'Dàn dây');
INSERT INTO PHANDOAN VALUES (N'Bản giao hưởng số 5', N'Beethoven', 2, N'Kèn đồng');
INSERT INTO PHANDOAN VALUES (N'Hồ Thiên Nga', N'Tchaikovsky', 1, N'Đàn dây');

-- CT_TACPHAM
INSERT INTO CT_TACPHAM VALUES (101, N'Bản giao hưởng số 5', N'Beethoven');
INSERT INTO CT_TACPHAM VALUES (102, N'Hồ Thiên Nga', N'Tchaikovsky');

-- NGUOIHATSOLO
INSERT INTO NGUOIHATSOLO VALUES (1, N'Ca sĩ A', '2025-05-01');
INSERT INTO NGUOIHATSOLO VALUES (2, N'Ca sĩ B', '2025-06-15');

-- SOLO_TACPHAM_CT
INSERT INTO SOLO_TACPHAM_CT VALUES (1, 101, N'Bản giao hưởng số 5', N'Beethoven');
INSERT INTO SOLO_TACPHAM_CT VALUES (2, 102, N'Hồ Thiên Nga', N'Tchaikovsky');

#12 câu hỏi 
#Cập nhật tên nhạc trưởng có mã 1 thành "Nhạc trưởng Quốc tế A".
UPDATE NHACTRUONG
SET TENNHACTRUONG = N'Nhạc trưởng Quốc tế A'
WHERE MANHACTRUONG = 1;
#Cập nhật NGAYCUOIHAT của tất cả ca sĩ solo đã biểu diễn tác phẩm "Hồ Thiên Nga" vào ngày 2025-06-15, thành ngày hiện tại.
UPDATE NGUOIHATSOLO
SET NGAYCUOIHAT = GETDATE()
WHERE MASOLO IN (
    SELECT MASOLO
    FROM SOLO_TACPHAM_CT
    WHERE TENTP = N'Hồ Thiên Nga' AND TENTG = N'Tchaikovsky' AND SOCT IN (
        SELECT SOCT FROM CHUONGTRINH WHERE NGAYBD = '2025-06-15'
    )
);
#câu cá nhân nghĩa
#Cập nhật TENPD của tất cả phân đoàn số 1 của tác phẩm "Bản giao hưởng số 5" thành "Dàn nhạc chính".
UPDATE PHANDOAN
SET TENPD = N'Dàn nhạc chính'
WHERE TENTP = N'Bản giao hưởng số 5' AND TENTG = N'Beethoven' AND SOPD = 1;
#Cập nhật giờ bắt đầu (GIOBD) thành "18:00" cho tất cả các chương trình có cùng ngày biểu diễn với Mã số ca sĩ solo 2.
UPDATE CHUONGTRINH
SET GIOBD = '18:00'
WHERE NGAYBD = (
    SELECT NGAYCUOIHAT FROM NGUOIHATSOLO WHERE MASOLO = 2
);
#Cập nhật tất cả ca sĩ solo chưa từng biểu diễn lần nào để ngày cuối hát (NGAYCUOIHAT) là NULL.
UPDATE NGUOIHATSOLO
SET NGAYCUOIHAT = NULL
WHERE MASOLO NOT IN (
    SELECT DISTINCT MASOLO FROM SOLO_TACPHAM_CT
);
#Cập nhật TENPD thành "Dàn phụ trách chính" cho các phân đoàn thuộc các tác phẩm đã được ca sĩ solo tên "Nguyễn Văn A" biểu diễn.
UPDATE PHANDOAN
SET TENPD = N'Dàn phụ trách chính'
WHERE EXISTS (
    SELECT 1
    FROM SOLO_TACPHAM_CT ST
    JOIN NGUOIHATSOLO NS ON ST.MASOLO = NS.MASOLO
    WHERE NS.TENSOLO = N'Nguyễn Văn A'
      AND ST.TENTP = PHANDOAN.TENTP
      AND ST.TENTG = PHANDOAN.TENTG
);
#Tăng thêm 1 giờ cho tất cả chương trình có ít nhất một tác phẩm của "Mozart":
UPDATE CHUONGTRINH
SET GIOBD = DATEADD(HOUR, 1, GIOBD)
WHERE SOCT IN (
    SELECT DISTINCT SOCT
    FROM CT_TACPHAM
    WHERE TENTG = N'Mozart'
);
#Cập nhật thêm hậu tố " - Tác giả yêu thích" vào TENSOLO của các ca sĩ solo nếu họ từng biểu diễn ít nhất 3 tác phẩm của nhạc sĩ "Beethoven".
UPDATE NGUOIHATSOLO
SET TENSOLO = TENSOLO + N' - Tác giả yêu thích'
WHERE MASOLO IN (
    SELECT MASOLO
    FROM SOLO_TACPHAM_CT
    WHERE TENTG = N'Beethoven'
    GROUP BY MASOLO
    HAVING COUNT(DISTINCT TENTP) >= 3
);
#Nếu một chương trình có từ 5 tác phẩm trở lên, cập nhật GIOBD của chương trình đó lùi lại 30 phút (để chuẩn bị sớm hơn).
UPDATE CHUONGTRINH
SET GIOBD = DATEADD(MINUTE, -30, GIOBD)
WHERE SOCT IN (
    SELECT SOCT
    FROM CT_TACPHAM
    GROUP BY SOCT
    HAVING COUNT(*) >= 5
);
# Xoá các phân đoàn chưa từng tham gia chương trình nào
DELETE FROM PHANDOAN
WHERE NOT EXISTS (
    SELECT 1
    FROM CT_TACPHAM CT
    WHERE CT.TENTP = PHANDOAN.TENTP AND CT.TENTG = PHANDOAN.TENTG
);
# Xóa ca sĩ solo không còn biểu diễn sau năm 2020
DELETE FROM NGUOIHATSOLO
WHERE NGAYCUOIHAT < '2021-01-01';
#Liệt kê tên ca sĩ solo đã từng biểu diễn nhiều nhất
SELECT TENSOLO
FROM NGUOIHATSOLO
WHERE MASOLO IN (
    SELECT TOP 1 WITH TIES MASOLO
    FROM SOLO_TACPHAM_CT
    GROUP BY MASOLO
    ORDER BY COUNT(*) DESC
);
#Liệt kê tên chương trình có tác phẩm chưa từng được biểu diễn solo
SELECT DISTINCT CT.SOCT, CT.NGAYBDCT
FROM CHUONGTRINH CT
JOIN CT_TACPHAM CTT ON CT.SOCT = CTT.SOCT
WHERE NOT EXISTS (
    SELECT 1
    FROM SOLO_TACPHAM_CT ST
    WHERE ST.SOCT = CT.SOCT AND ST.TENTP = CTT.TENTP AND ST.TENTG = CTT.TENTG
);
#Câu hỏi cá nhân huy
#Cập nhật NGAYCUOIHAT thành ngày hiện tại cho các ca sĩ solo có ít nhất một tác phẩm biểu diễn sau năm 2024.
UPDATE NGUOIHATSOLO
SET NGAYCUOIHAT = GETDATE()
WHERE MASOLO IN (
    SELECT MASOLO
    FROM SOLO_TACPHAM_CT ST
    JOIN CHUONGTRINH CT ON ST.SOCT = CT.SOCT
    WHERE CT.NGAYBDCT > '2024-01-01'
);
#Xoá các chương trình chỉ có đúng 1 tác phẩm.
DELETE FROM CHUONGTRINH
WHERE SOCT IN (
    SELECT SOCT
    FROM CT_TACPHAM
    GROUP BY SOCT
    HAVING COUNT(*) = 1
);
#Liệt kê mã chương trình có hơn 2 ca sĩ solo khác nhau biểu diễn.
SELECT SOCT
FROM SOLO_TACPHAM_CT
GROUP BY SOCT
HAVING COUNT(DISTINCT MASOLO) > 2;
#Liệt kê các tác phẩm từng có phân đoàn biểu diễn.
SELECT DISTINCT TENTP, TENTG
FROM TACPHAM TP
WHERE EXISTS (
    SELECT 1
    FROM PHANDOAN PD
    WHERE PD.TENTP = TP.TENTP AND PD.TENTG = TP.TENTG
);
#Câu groupby
#Liệt kê mã chương trình và số lượng tác phẩm được biểu diễn trong chương trình đó.
SELECT SOCT, COUNT(*) AS SoLuongTacPham
FROM CT_TACPHAM
GROUP BY SOCT;
#Hiển thị mã ca sĩ solo và số lần họ biểu diễn trong các chương trình.
SELECT MASOLO, COUNT(*) AS SoLanBieuDien
FROM SOLO_TACPHAM_CT
GROUP BY MASOLO;
#Câu cá nhân rô
#Liệt kê tất cả các tác phẩm đã từng được biểu diễn bởi ca sĩ solo.
SELECT DISTINCT TP.TENTP, TP.TENTG
FROM TACPHAM TP
JOIN SOLO_TACPHAM_CT ST ON TP.TENTP = ST.TENTP AND TP.TENTG = ST.TENTG;
#Tìm các tác phẩm được biểu diễn solo từ 2 ca sĩ solo trở lên.
SELECT TENTP, TENTG
FROM SOLO_TACPHAM_CT
GROUP BY TENTP, TENTG
HAVING COUNT(DISTINCT MASOLO) >= 2;
#Cập nhật NGAYCUOIHAT của ca sĩ solo thành ngày biểu diễn gần nhất mà họ tham gia.
UPDATE NS
SET NGAYCUOIHAT = MAXDATE
FROM NGUOIHATSOLO NS
JOIN (
    SELECT MASOLO, MAX(NGAYBDCT) AS MAXDATE
    FROM SOLO_TACPHAM_CT ST
    JOIN CHUONGTRINH CT ON ST.SOCT = CT.SOCT
    GROUP BY MASOLO
) AS L ON NS.MASOLO = L.MASOLO;
#Xóa các bản ghi trong bảng SOLO_TACPHAM_CT của những tác phẩm do tác giả "Beethoven" sáng tác.
DELETE ST
FROM SOLO_TACPHAM_CT ST
JOIN TACPHAM TP ON ST.TENTP = TP.TENTP AND ST.TENTG = TP.TENTG
WHERE TP.TENTG = 'Beethoven';
#Lan
#Liệt kê tên các nhạc công đã từng biểu diễn mọi bản nhạc ít nhất một lần
SELECT NC.HoTen
FROM NHACCONG NC
JOIN CHITIETBD CT ON NC.MaNC = CT.MaNC
JOIN BIEUDIEN BD ON CT.MaBD = BD.MaBD
GROUP BY NC.MaNC, NC.HoTen
HAVING COUNT(DISTINCT BD.MaBN) = (
    SELECT COUNT(*) FROM BANNHAC
);
#Tìm cặp nhạc công cùng biểu diễn 1 buổi và chơi cùng loại nhạc cụ
SELECT 
    CT1.MaNC AS MaNC1, 
    CT2.MaNC AS MaNC2, 
    CT1.MaBD, 
    CT1.MaNCu
FROM CHITIETBD CT1
JOIN CHITIETBD CT2 
    ON CT1.MaBD = CT2.MaBD
   AND CT1.MaNCu = CT2.MaNCu
   AND CT1.MaNC < CT2.MaNC;
#Liệt kê tên mỗi loại nhạc cụ cùng với số lượng nhạc công khác nhau có thể chơi được loại nhạc cụ đó. Chỉ hiển thị những loại nhạc cụ có ít nhất 2 nhạc công chơi được.
SELECT NC.TenNCu, COUNT(DISTINCT CN.MaNC) AS SoLuongNhacCong
FROM NHACCU NC
JOIN CHOINHACCU CN ON NC.MaNCu = CN.MaNCu
GROUP BY NC.TenNCu
HAVING COUNT(DISTINCT CN.MaNC) >= 2;





















