class PenyakitParu {
  // Map untuk informasi tambahan setiap penyakit
  static final Map<String, Map<String, String>> penyakitInfo = {
    'Pneumonia': {
      'description': 'Infeksi paru-paru yang menyebabkan kantung udara di paru-paru (alveoli) meradang dan terisi cairan.',
      'treatment': 'Antibiotik, istirahat cukup, cairan yang memadai, dan manajemen gejala.',
      'icon': 'waveform_path',
    },
    'Tuberkulosis (TBC paru)': {
      'description': 'Penyakit infeksi yang disebabkan oleh bakteri Mycobacterium tuberculosis dan menyerang paru-paru.',
      'treatment': 'Pengobatan antibiotik spesifik selama minimal 6 bulan, pemantauan rutin, dan tindakan pencegahan penularan.',
      'icon': 'waveform_path_ecg',
    },
    'Asma bronkial': {
      'description': 'Kondisi kronis yang menyebabkan pembengkakan dan penyempitan saluran udara paru.',
      'treatment': 'Pengobatan pengontrol dan pelega, identifikasi dan hindari pemicu, kontrol rutin.',
      'icon': 'wind',
    },
    'Bronkitis akut': {
      'description': 'Peradangan sementara pada bronkus (saluran udara ke paru-paru) yang biasanya disebabkan oleh infeksi.',
      'treatment': 'Istirahat, minum banyak cairan, obat pereda gejala, dan kadang bronkodilator.',
      'icon': 'waveform_path',
    },
    'Bronkitis kronis': {
      'description': 'Peradangan jangka panjang pada saluran pernapasan yang menyebabkan batuk produktif berkepanjangan.',
      'treatment': 'Berhenti merokok, bronkodilator, kortikosteroid inhalasi, dan pencegahan infeksi.',
      'icon': 'waveform_path',
    },
    'Penyakit Paru Obstruktif Kronik (PPOK)': {
      'description': 'Penyakit paru progresif yang menyebabkan kesulitan bernapas karena penyempitan saluran udara.',
      'treatment': 'Bronkodilator, steroid inhalasi, terapi oksigen, rehabilitasi paru, berhenti merokok.',
      'icon': 'exclamationmark_shield',
    },
    'Emfisema paru': {
      'description': 'Kondisi dimana kantung udara paru-paru (alveoli) rusak dan melebar, mengurangi area pertukaran oksigen.',
      'treatment': 'Berhenti merokok, bronkodilator, terapi oksigen, kadang pembedahan reduksi volume paru.',
      'icon': 'exclamationmark_shield',
    },
    'Fibrosis paru idiopatik': {
      'description': 'Penyakit paru progresif yang menyebabkan penebalan dan jaringan parut pada paru-paru.',
      'treatment': 'Obat antifibrotik, terapi oksigen, rehabilitasi paru, transplantasi paru untuk kasus berat.',
      'icon': 'waveform_path_ecg',
    },
    'Sarkoidosis paru': {
      'description': 'Penyakit inflamasi yang ditandai dengan pembentukan granuloma di berbagai organ, termasuk paru-paru.',
      'treatment': 'Kortikosteroid, imunosupresan, dan pengobatan simptomatik.',
      'icon': 'waveform_path_ecg',
    },
    'Edema paru': {
      'description': 'Penumpukan cairan di paru-paru yang dapat disebabkan oleh gagal jantung atau kondisi lain.',
      'treatment': 'Pengobatan penyebab dasar, diuretik, oksigen, posisi duduk, dan obat-obatan untuk jantung.',
      'icon': 'drop_fill',
    },
    'Emboli paru': {
      'description': 'Sumbatan pada arteri paru-paru, biasanya akibat bekuan darah yang terbawa dari bagian tubuh lain.',
      'treatment': 'Pengencer darah (antikoagulan), penghancur bekuan darah (trombolitik), filter vena kava inferior.',
      'icon': 'arrow_circlepath',
    },
    'Infeksi saluran pernapasan bawah': {
      'description': 'Infeksi pada saluran pernapasan di bawah laring, termasuk trakea, bronkus, dan paru-paru.',
      'treatment': 'Antibiotik, antivirus, istirahat, cairan yang cukup, dan obat pereda gejala.',
      'icon': 'waveform_path',
    },
    'COVID-19': {
      'description': 'Penyakit pernapasan menular yang disebabkan oleh virus SARS-CoV-2.',
      'treatment': 'Perawatan suportif, isolasi, obat antivirus, oksigen, dan antibiotik jika ada infeksi sekunder.',
      'icon': 'exclamationmark_shield_fill',
    },
    'ARDS': {
      'description': 'Sindrom gangguan pernapasan akut yang menyebabkan peradangan luas dan kebocoran cairan di paru-paru.',
      'treatment': 'Perawatan suportif, ventilasi mekanis, penanganan penyakit yang mendasari.',
      'icon': 'waveform_path_ecg',
    },
    'Kanker paru-paru': {
      'description': 'Pertumbuhan sel ganas di paru-paru yang dapat menyebar ke bagian tubuh lain.',
      'treatment': 'Pembedahan, kemoterapi, radioterapi, terapi target, dan imunoterapi berdasarkan jenis dan stadium.',
      'icon': 'waveform_path_ecg',
    },
    'Pneumotoraks': {
      'description': 'Kebocoran udara ke dalam rongga pleura yang menyebabkan paru-paru kolaps sebagian atau seluruhnya.',
      'treatment': 'Observasi untuk kasus ringan, pemasangan selang dada, kadang memerlukan tindakan bedah.',
      'icon': 'waveform_path_ecg',
    },
    'Atelektasis': {
      'description': 'Kolaps sebagian atau seluruh paru-paru karena penyumbatan atau tekanan dari luar.',
      'treatment': 'Penanganan penyebab dasar, fisioterapi dada, bronkoskopi untuk menghilangkan sumbatan.',
      'icon': 'waveform_path',
    },
    'Silikosis': {
      'description': 'Penyakit paru akibat menghirup debu silika kristal dalam jangka panjang.',
      'treatment': 'Tidak ada pengobatan spesifik, terapi oksigen, pengobatan infeksi sekunder, transplantasi paru untuk kasus berat.',
      'icon': 'exclamationmark_shield',
    },
    'Asbestosis': {
      'description': 'Penyakit paru akibat menghirup serat asbes dalam jangka panjang.',
      'treatment': 'Tidak ada pengobatan spesifik, terapi oksigen, pengobatan infeksi sekunder, rehabilitasi paru.',
      'icon': 'exclamationmark_shield',
    },
    'Pneumokoniosis': {
      'description': 'Sekelompok penyakit paru akibat menghirup debu mineral dalam jangka panjang.',
      'treatment': 'Menghindari paparan lebih lanjut, terapi oksigen, pengobatan gejala, dan rehabilitasi paru.',
      'icon': 'exclamationmark_shield',
    },
    'Paru-paru hitam (black lung disease)': {
      'description': 'Jenis pneumokoniosis yang disebabkan oleh inhalasi debu batu bara dalam jangka panjang.',
      'treatment': 'Tidak ada pengobatan spesifik, terapi oksigen, rehabilitasi paru, dan penghindaran paparan lebih lanjut.',
      'icon': 'exclamationmark_shield',
    },
    'Bronkiektasis': {
      'description': 'Pelebaran abnormal dari saluran udara (bronkus) akibat infeksi atau peradangan kronis.',
      'treatment': 'Drainase postural, antibiotik, bronkodilator, terapi fisik, dan dalam kasus parah mungkin memerlukan pembedahan.',
      'icon': 'waveform_path',
    },
    'Pleuritis': {
      'description': 'Peradangan pada pleura, lapisan yang menutupi paru-paru dan rongga dada.',
      'treatment': 'Pengobatan penyebab dasar, obat anti-inflamasi, analgesik untuk nyeri.',
      'icon': 'waveform_path',
    },
    'Efusi pleura': {
      'description': 'Penumpukan cairan di ruang pleura (antara paru-paru dan dinding dada).',
      'treatment': 'Pengobatan penyakit dasar, drainase pleura (torakosentesis), kadang perlu pleurodesis.',
      'icon': 'drop_fill',
    },
    'Hipertensi pulmonal': {
      'description': 'Tekanan darah tinggi pada arteri paru-paru dan sisi kanan jantung.',
      'treatment': 'Obat vasodilatator, diuretik, antikoagulan, terapi oksigen, transplantasi paru-jantung untuk kasus berat.',
      'icon': 'waveform_path_ecg',
    },
    'Paru-paru basah': {
      'description': 'Istilah umum untuk kondisi dengan akumulasi cairan di paru-paru, seperti pneumonia atau edema paru.',
      'treatment': 'Pengobatan tergantung penyebab dasar, dapat termasuk antibiotik, diuretik, dan terapi oksigen.',
      'icon': 'drop_fill',
    },
    'Hantavirus pulmonary syndrome': {
      'description': 'Penyakit pernapasan parah yang disebabkan oleh infeksi virus Hantavirus.',
      'treatment': 'Perawatan suportif intens, terapi oksigen, ventilasi mekanis untuk kasus parah.',
      'icon': 'exclamationmark_shield_fill',
    },
    'Histoplasmosis': {
      'description': 'Infeksi jamur yang disebabkan oleh Histoplasma capsulatum yang biasanya masuk melalui saluran pernapasan.',
      'treatment': 'Obat antijamur untuk kasus yang parah, perawatan suportif untuk kasus ringan.',
      'icon': 'waveform_path',
    },
    'Aspergillosis paru': {
      'description': 'Infeksi jamur yang disebabkan oleh Aspergillus yang dapat menyerang paru-paru.',
      'treatment': 'Obat antijamur, pembedahan pada kasus tertentu.',
      'icon': 'waveform_path_ecg',
    },
    'Kandidiasis paru': {
      'description': 'Infeksi jamur pada paru-paru yang disebabkan oleh Candida, biasanya terjadi pada orang dengan sistem kekebalan lemah.',
      'treatment': 'Obat antijamur, pengobatan untuk meningkatkan daya tahan tubuh.',
      'icon': 'waveform_path',
    },
    'Legionellosis': {
      'description': 'Infeksi bakteri Legionella yang dapat menyebabkan pneumonia serius (penyakit Legionnaire).',
      'treatment': 'Antibiotik spesifik, terapi oksigen, dan perawatan suportif.',
      'icon': 'exclamationmark_shield',
    },
    'Mycoplasma pneumonia': {
      'description': 'Jenis pneumonia yang disebabkan oleh bakteri Mycoplasma pneumoniae.',
      'treatment': 'Antibiotik makrolida, istirahat, dan cairan yang cukup.',
      'icon': 'waveform_path',
    },
    'Bronkiolitis': {
      'description': 'Infeksi pada bronkiol (saluran udara kecil) di paru-paru, biasanya memengaruhi bayi dan anak kecil.',
      'treatment': 'Perawatan suportif, oksigen, hidrasi, kadang bronkodilator.',
      'icon': 'waveform_path',
    },
    'Cystic fibrosis': {
      'description': 'Penyakit genetik yang menyebabkan kerusakan progresif pada paru-paru dan sistem pencernaan.',
      'treatment': 'Terapi pengeluaran lendir, antibiotik, enzim pankreas, dan terapi gen pada beberapa kasus.',
      'icon': 'waveform_path_ecg',
    },
    'Pulmonary alveolar proteinosis': {
      'description': 'Penyakit langka di mana material protein menumpuk di alveoli dan menghalangi pertukaran gas.',
      'treatment': 'Lavage seluruh paru (whole lung lavage), terapi GM-CSF, transplantasi paru dalam kasus parah.',
      'icon': 'waveform_path_ecg',
    },
    'Pulmonary sequestration': {
      'description': 'Kelainan kongenital di mana sebagian jaringan paru tidak terhubung normal dengan sistem pernapasan.',
      'treatment': 'Pembedahan untuk mengangkat bagian paru yang abnormal.',
      'icon': 'waveform_path',
    },
    'Lymphangioleiomyomatosis (LAM)': {
      'description': 'Penyakit langka yang menyebabkan pertumbuhan sel otot polos abnormal di paru-paru.',
      'treatment': 'Sirolimus/everolimus, penanganan komplikasi, transplantasi paru untuk kasus parah.',
      'icon': 'waveform_path_ecg',
    },
    'Hypersensitivity pneumonitis': {
      'description': 'Peradangan paru akibat reaksi alergi terhadap zat yang terhirup, seperti jamur atau protein organik.',
      'treatment': 'Menghindari pemicu, kortikosteroid, dan kadang imunosupresan.',
      'icon': 'exclamationmark_shield',
    },
    'Pneumonia aspirasi': {
      'description': 'Peradangan paru akibat menghirup makanan, cairan, atau muntah ke dalam paru-paru.',
      'treatment': 'Antibiotik, terapi oksigen, fisioterapi dada, dan penanganan penyebab dasar.',
      'icon': 'drop_fill',
    },
    'Pneumonia nosokomial': {
      'description': 'Pneumonia yang didapat selama perawatan di rumah sakit, biasanya 48 jam atau lebih setelah masuk.',
      'treatment': 'Antibiotik spektrum luas, identifikasi patogen, dan pencegahan komplikasi.',
      'icon': 'waveform_path',
    },
    'Pneumonia komunitas': {
      'description': 'Pneumonia yang didapat di luar lingkungan rumah sakit atau fasilitas kesehatan.',
      'treatment': 'Antibiotik berdasarkan patogen yang dicurigai, istirahat, dan cairan yang cukup.',
      'icon': 'waveform_path',
    },
    'Pneumonia atipikal': {
      'description': 'Pneumonia yang disebabkan oleh patogen tidak biasa seperti Mycoplasma, Chlamydia, atau Legionella.',
      'treatment': 'Antibiotik makrolida, quinolon, atau tetrasiklin, dan perawatan suportif.',
      'icon': 'waveform_path',
    },
    'Pneumonia eosinofilik': {
      'description': 'Infiltrasi eosinofil (jenis sel darah putih) di paru-paru, biasanya terkait dengan kondisi alergi.',
      'treatment': 'Kortikosteroid, pengobatan penyebab dasar, kadang obat imunosupresan.',
      'icon': 'waveform_path_ecg',
    },
    'Pneumonia interstisial': {
      'description': 'Sekelompok gangguan paru-paru yang memengaruhi jaringan dan ruang di sekitar alveoli (kantung udara).',
      'treatment': 'Tergantung jenis spesifik, dapat termasuk kortikosteroid, imunosupresan, antifibrotik.',
      'icon': 'waveform_path_ecg',
    },
    'Granulomatosis dengan poliangitis': {
      'description': 'Penyakit autoimun langka yang menyebabkan peradangan pada pembuluh darah kecil dan sedang, terutama di paru-paru dan ginjal.',
      'treatment': 'Kortikosteroid, siklofosfamid, rituximab, dan imunosupresan lainnya.',
      'icon': 'exclamationmark_shield',
    },
    'Tuberkulosis milier': {
      'description': 'Bentuk parah TBC di mana bakteri menyebar melalui aliran darah dan menginfeksi banyak organ.',
      'treatment': 'Regimen antibiotik kombinasi selama minimal 6-9 bulan.',
      'icon': 'waveform_path_ecg',
    },
    'Tuberkuloma': {
      'description': 'Lesi nodular di paru-paru yang disebabkan oleh infeksi tuberkulosis terlokalisasi.',
      'treatment': 'Pengobatan standar TBC dengan antibiotik kombinasi selama 6-9 bulan.',
      'icon': 'waveform_path_ecg',
    },
    'Tuberkulosis kelenjar mediastinum': {
      'description': 'Infeksi TBC pada kelenjar getah bening di mediastinum (ruang diantara paru-paru).',
      'treatment': 'Pengobatan antibiotik anti-TBC selama 6-12 bulan.',
      'icon': 'waveform_path_ecg',
    },
    'MDR-TB (Multi-drug resistant TB)': {
      'description': 'Tuberkulosis yang resisten terhadap setidaknya isoniazid dan rifampisin, dua obat anti-TBC lini pertama.',
      'treatment': 'Regimen obat yang lebih kompleks, lebih toksik dan digunakan lebih lama (18-24 bulan).',
      'icon': 'exclamationmark_shield_fill',
    },
    'XDR-TB (Extensively drug-resistant TB)': {
      'description': 'TBC yang resisten terhadap isoniazid, rifampisin, fluoroquinolon, dan setidaknya satu obat injeksi lini kedua.',
      'treatment': 'Regimen obat sangat kompleks dengan durasi lebih lama dan hasil pengobatan yang lebih buruk.',
      'icon': 'exclamationmark_shield_fill',
    },
    'Cryptogenic organizing pneumonia': {
      'description': 'Kondisi inflamasi paru yang menyebabkan jaringan granulasi terbentuk di saluran udara kecil dan alveoli.',
      'treatment': 'Kortikosteroid, kadang imunosupresan jika tidak merespons steroid.',
      'icon': 'waveform_path_ecg',
    },
    'Lipoid pneumonia': {
      'description': 'Kondisi langka di mana lemak masuk ke dalam paru-paru, menyebabkan reaksi inflamasi kronis.',
      'treatment': 'Menghindari paparan lemak, kortikosteroid, lavage bronkoalveolar pada kasus tertentu.',
      'icon': 'drop_fill',
    },
    'Bronchiolitis obliterans': {
      'description': 'Penyakit obstruktif paru progresif yang merusak bronkiol, sering terjadi setelah transplantasi atau paparan toksin.',
      'treatment': 'Tergantung penyebab - kortikosteroid, imunosupresan, bronkodilator, dan kadang transplantasi paru.',
      'icon': 'exclamationmark_shield',
    },
    'Pulmonary veno-occlusive disease (PVOD)': {
      'description': 'Penyakit langka yang menyebabkan penyumbatan progresif pada vena pulmonalis.',
      'treatment': 'Terapi suportif, vasodilatator pulmonaris dengan hati-hati, transplantasi paru-jantung.',
      'icon': 'waveform_path_ecg',
    },
    'Pulmonary capillary hemangiomatosis': {
      'description': 'Proliferasi abnormal kapiler paru-paru yang menginfiltrasi dinding pembuluh darah dan jaringan paru.',
      'treatment': 'Terapi suportif, transplantasi paru sebagai pengobatan definit.',
      'icon': 'waveform_path_ecg',
    },
    'Goodpasture syndrome': {
      'description': 'Penyakit autoimun langka yang menyerang paru-paru dan ginjal akibat antibodi terhadap membran basal.',
      'treatment': 'Plasmaferesis, kortikosteroid, siklofosfamid atau rituximab.',
      'icon': 'exclamationmark_shield',
    },
    'Wegener\'s granulomatosis': {
      'description': 'Penyakit autoimun yang menyebabkan peradangan pembuluh darah dan terbentuknya granuloma, terutama di saluran pernapasan dan ginjal.',
      'treatment': 'Kortikosteroid, siklofosfamid, rituximab, dan imunosupresan lainnya.',
      'icon': 'exclamationmark_shield',
    },
    'Churg-Strauss syndrome (EGPA)': {
      'description': 'Vaskulitis sistemik langka yang memengaruhi pembuluh darah kecil dan sedang, terkait dengan asma dan eosinofilia.',
      'treatment': 'Kortikosteroid, imunosupresan, kadang terapi biologis seperti mepolizumab.',
      'icon': 'exclamationmark_shield',
    },
    'Pneumonia interstitial nonspesifik': {
      'description': 'Jenis pneumonia interstisial dengan pola inflamasi dan fibrosis yang homogen pada seluruh lapisan paru.',
      'treatment': 'Kortikosteroid, imunosupresan, antifibrotik pada kasus tertentu.',
      'icon': 'waveform_path_ecg',
    },
    'Acute interstitial pneumonia': {
      'description': 'Bentuk penyakit paru interstisial akut yang cepat berkembang, menyebabkan gagal napas dan memiliki prognosis buruk.',
      'treatment': 'Terapi suportif agresif, ventilasi mekanis, kortikosteroid dosis tinggi.',
      'icon': 'exclamationmark_shield_fill',
    },
    'Sarcoidosis stadium lanjut': {
      'description': 'Tahap lanjut sarkoidosis dengan fibrosis paru yang signifikan dan kehilangan fungsi paru permanen.',
      'treatment': 'Kortikosteroid, imunosupresan, terapi oksigen, transplantasi paru untuk kasus parah.',
      'icon': 'waveform_path_ecg',
    },
    'Amyloidosis paru': {
      'description': 'Penumpukan protein abnormal (amiloid) di jaringan paru-paru.',
      'treatment': 'Pengobatan penyakit dasar, terapi untuk mengurangi produksi amiloid, transplantasi untuk kasus tertentu.',
      'icon': 'waveform_path_ecg',
    },
    'Pulmonary lymphangiomatosis': {
      'description': 'Proliferasi abnormal pembuluh limfatik di paru-paru dan organ lain.',
      'treatment': 'Sirolimus/rapamycin, pengobatan simptomatik, terapi interferons pada beberapa kasus.',
      'icon': 'waveform_path',
    },
    'Tumor karsinoid paru': {
      'description': 'Tumor neuroendokrin yang lambat tumbuh, biasanya terletak di bronkus utama.',
      'treatment': 'Pembedahan, terapi biologis atau kemoterapi untuk penyakit metastatik.',
      'icon': 'waveform_path_ecg',
    },
    'Mesotelioma pleura': {
      'description': 'Kanker langka yang memengaruhi mesothelium (lapisan pleura), sering terkait dengan paparan asbes.',
      'treatment': 'Pembedahan, kemoterapi, radioterapi, terapi multimodal untuk kasus tertentu.',
      'icon': 'waveform_path_ecg',
    },
    'Infark paru': {
      'description': 'Kematian jaringan paru akibat gangguan suplai darah, sering disebabkan oleh emboli paru.',
      'treatment': 'Pengobatan penyebab dasar (biasanya antikoagulan), terapi oksigen, perawatan suportif.',
      'icon': 'exclamationmark_shield',
    },
    'Tuberkulosis pleura': {
      'description': 'Infeksi tuberkulosis yang memengaruhi pleura, seringkali menyebabkan efusi pleura.',
      'treatment': 'Antibiotik anti-TB, kadang drainase cairan pleura atau dekortikasi.',
      'icon': 'waveform_path_ecg',
    },
    'Idiopathic pulmonary hemosiderosis': {
      'description': 'Penyakit langka yang ditandai dengan perdarahan paru berulang dan pengendapan hemosiderin di paru-paru.',
      'treatment': 'Kortikosteroid, imunosupresan, transfusi darah jika anemia parah.',
      'icon': 'drop_fill',
    },
    'Recurrent respiratory papillomatosis': {
      'description': 'Pertumbuhan berulang papiloma (tumor jinak) pada saluran pernapasan, disebabkan oleh HPV.',
      'treatment': 'Pembedahan berulang, terapi laser, interferon, cidofovir, atau vaksinasi HPV untuk pencegahan.',
      'icon': 'waveform_path',
    },
    'Alveolitis alergika ekstrinsik': {
      'description': 'Reaksi alergi pada jaringan paru akibat menghirup debu organik atau partikel berulang kali.',
      'treatment': 'Menghindari alergen penyebab, kortikosteroid untuk kasus sedang hingga berat.',
      'icon': 'exclamationmark_shield',
    },
    // 'Sleep Apnea': {
    //   'description': 'Gangguan tidur di mana pernapasan berulang kali berhenti dan dimulai kembali selama tidur.',
    //   'treatment': 'CPAP, alat bantu mulut, perubahan gaya hidup, operasi pada kasus tertentu.',
    //   'icon': 'bed_double_fill',
    // },
    // 'Aspirasi paru': {
    //   'description': 'Kondisi dimana benda asing, makanan, atau cairan masuk ke dalam saluran napas atau paru-paru.',
    //   'treatment': 'Membersihkan saluran napas, antibiotik jika terjadi infeksi, terapi pernapasan.',
    //   'icon': 'drop_fill',
    // },
    'Sehat': {
    'description': 'Kondisi tubuh yang berfungsi secara normal tanpa gejala atau gangguan kesehatan tertentu.',
    'treatment': 'Tidak memerlukan penanganan medis. Menjaga pola hidup sehat, olahraga rutin, makan bergizi, tidur cukup, dan mengelola stres penting untuk mempertahankan kesehatan.',
    'icon': 'wellness',
    },
    'Normal': {
    'description': 'Kondisi tubuh kemungkinan berada dalam batas normal. Tidak ditemukan kelainan atau gejala yang mengarah pada suatu penyakit khusus.',
    'treatment': 'Tidak diperlukan penanganan khusus. Disarankan tetap menjaga pola hidup sehat dan melakukan pemeriksaan rutin bila diperlukan.',
    'icon': 'check_circle',
    },
  };
}