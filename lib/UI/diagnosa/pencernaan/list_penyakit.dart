class PenyakitPencernaan {
  // Map untuk informasi tambahan setiap penyakit
  static final Map<String, Map<String, String>> penyakitInfo = {
    'Gastroesophageal Reflux Disease (GERD)': {
      'description': 'Kondisi kronis dimana asam lambung dan isi lambung naik kembali ke esofagus, menyebabkan iritasi pada lapisan esofagus.',
      'treatment': 'Perubahan gaya hidup, obat antasida, penghambat pompa proton (PPI), penghambat reseptor H2, dan pada kasus berat mungkin diperlukan pembedahan.',
      'icon': 'flame',
    },
    'Esofagitis (radang esofagus)': {
      'description': 'Peradangan pada esofagus yang biasanya disebabkan oleh refluks asam, infeksi, atau reaksi alergi.',
      'treatment': 'Pengobatan tergantung penyebab, termasuk antasida, PPI, antibiotik untuk infeksi, atau kortikosteroid untuk esofagitis eosinofilik.',
      'icon': 'waveform_path',
    },
    'Akalasia': {
      'description': 'Gangguan motilitas esofagus dimana sfingter esofagus bagian bawah tidak dapat rileks dengan baik dan peristaltik esofagus terganggu.',
      'treatment': 'Dilatasi pneumatik, miotomi Heller, atau miotomi endoskopik per-oral (POEM).',
      'icon': 'arrow_down_circle',
    },
    'Varises esofagus': {
      'description': 'Pembuluh darah yang membengkak di dinding esofagus, sering terjadi pada pasien dengan sirosis hati dan hipertensi portal.',
      'treatment': 'Ligasi pita endoskopik, terapi skleroterapi, obat beta-blocker, dan penanganan penyakit hati yang mendasari.',
      'icon': 'drop_fill',
    },
    'Striktur esofagus': {
      'description': 'Penyempitan abnormal pada esofagus yang dapat disebabkan oleh jaringan parut akibat refluks kronis atau cedera lainnya.',
      'treatment': 'Dilatasi esofagus, pemasangan stent, atau pada kasus tertentu mungkin diperlukan pembedahan.',
      'icon': 'arrow_up_arrow_down',
    },
    'Barrett\'s esophagus': {
      'description': 'Kondisi dimana lapisan esofagus mengalami perubahan sel menjadi sel-sel yang mirip dengan sel di usus, sering dikaitkan dengan GERD kronis.',
      'treatment': 'Pengobatan GERD yang mendasari, pemantauan endoskopi rutin, ablasi endoskopik untuk displasia, dan pada kasus tertentu pembedahan.',
      'icon': 'exclamationmark_shield',
    },
    'Kanker esofagus': {
      'description': 'Pertumbuhan sel ganas di esofagus, biasanya terbagi menjadi karsinoma sel skuamosa dan adenokarsinoma.',
      'treatment': 'Tergantung stadium: pembedahan, kemoterapi, radioterapi, terapi target, atau kombinasi dari berbagai pendekatan.',
      'icon': 'exclamationmark_shield_fill',
    },
    'Esofagus ruptur (Boerhaave syndrome)': {
      'description': 'Robekan pada dinding esofagus, seringkali akibat muntah keras, trauma, atau prosedur endoskopi.',
      'treatment': 'Penanganan bedah segera, drainase, antibiotik spektrum luas, dan dukungan nutrisi.',
      'icon': 'exclamationmark_circle_fill',
    },
    'Divertikulum Zenker': {
      'description': 'Kantong abnormal yang terbentuk pada dinding faring-esofagus bagian atas, biasanya akibat peningkatan tekanan.',
      'treatment': 'Pada kasus simptomatik: miotomi krikofaringeal, divertikulektomi, atau pendekatan endoskopik.',
      'icon': 'arrow_up_doc',
    },
    'Esofagospasme difus': {
      'description': 'Gangguan motilitas esofagus yang ditandai dengan kontraksi abnormal otot esofagus.',
      'treatment': 'Obat relaksan otot, penghambat saluran kalsium, nitrat, dan pada kasus tertentu intervensi endoskopik atau bedah.',
      'icon': 'waveform_path',
    },
    'Gastritis akut': {
      'description': 'Peradangan mendadak pada lapisan lambung, sering disebabkan oleh infeksi, alkohol, obat NSAID, atau stres.',
      'treatment': 'Penghilangan penyebab, antasida, PPI, penghambat reseptor H2, dan antibiotik jika disebabkan oleh infeksi H. pylori.',
      'icon': 'waveform_path',
    },
    'Gastritis kronis': {
      'description': 'Peradangan jangka panjang pada lapisan lambung, sering dikaitkan dengan infeksi H. pylori atau kondisi autoimun.',
      'treatment': 'Pengobatan infeksi H. pylori, PPI, dan pada gastritis autoimun mungkin diperlukan suplementasi vitamin B12.',
      'icon': 'waveform_path_ecg',
    },
    'Ulkus gaster (tukak lambung)': {
      'description': 'Luka terbuka pada lapisan lambung, seringkali disebabkan oleh infeksi H. pylori atau penggunaan NSAID jangka panjang.',
      'treatment': 'Eradikasi H. pylori, PPI, penghilangan faktor pemicu, dan pada kasus komplikasi mungkin diperlukan pembedahan.',
      'icon': 'bandage',
    },
    'Ulkus duodenum': {
      'description': 'Luka terbuka pada lapisan duodenum (bagian awal usus halus), sering disebabkan oleh infeksi H. pylori atau NSAID.',
      'treatment': 'Mirip dengan ulkus gaster: eradikasi H. pylori, PPI, dan penghilangan faktor pemicu.',
      'icon': 'bandage',
    },
    'Gastroparesis': {
      'description': 'Kelainan motilitas dimana lambung mengalami kelambatan dalam mengosongkan isinya, sering terkait dengan diabetes.',
      'treatment': 'Modifikasi diet, prokinetik, antiemetik, dan pada kasus berat mungkin diperlukan stimulasi listrik lambung atau pembedahan.',
      'icon': 'arrow_down_circle',
    },
    'Dispepsia fungsional': {
      'description': 'Nyeri atau ketidaknyamanan kronis di perut bagian atas tanpa adanya kelainan struktural yang terdeteksi.',
      'treatment': 'Perubahan gaya hidup, PPI, prokinetik, antidepresan dosis rendah, dan terapi anti-kecemasan bila diperlukan.',
      'icon': 'waveform_path',
    },
    'Kanker lambung': {
      'description': 'Pertumbuhan sel ganas di lambung, sering dikaitkan dengan infeksi H. pylori kronis, faktor genetik, atau pola makan tertentu.',
      'treatment': 'Tergantung stadium: pembedahan, kemoterapi, radioterapi, terapi target, atau pendekatan gabungan.',
      'icon': 'exclamationmark_shield_fill',
    },
    'Polip lambung': {
      'description': 'Pertumbuhan abnormal pada lapisan lambung, kebanyakan jinak tetapi beberapa jenis memiliki potensi keganasan.',
      'treatment': 'Pengangkatan polip secara endoskopi, pemantauan rutin, dan pada kasus tertentu mungkin diperlukan pembedahan.',
      'icon': 'circle',
    },
    'Perforasi lambung': {
      'description': 'Lubang pada dinding lambung yang memungkinkan isi lambung bocor ke rongga perut, sering merupakan komplikasi dari ulkus.',
      'treatment': 'Pembedahan darurat, antibiotik, dan perawatan suportif intensif.',
      'icon': 'exclamationmark_circle_fill',
    },
    'Sindrom Zollinger-Ellison': {
      'description': 'Kondisi langka dimana terjadi produksi hormon gastrin berlebihan, biasanya oleh tumor (gastrinoma), menyebabkan ulkus berulang.',
      'treatment': 'PPI dosis tinggi, pengangkatan tumor jika memungkinkan, dan terapi untuk mengatasi metastasis bila ada.',
      'icon': 'waveform_path_ecg',
    },
    'Irritable Bowel Syndrome (IBS)': {
      'description': 'Gangguan fungsional usus kronis yang ditandai dengan nyeri perut, perubahan pola BAB, dan kembung tanpa kelainan struktural.',
      'treatment': 'Modifikasi diet, manajemen stres, obat antispasmodic, laksatif untuk IBS-C, antidiare untuk IBS-D, dan antidepresan pada kasus tertentu.',
      'icon': 'waveform_path',
    },
    'Inflammatory Bowel Disease (IBD)': {
      'description': 'Sekelompok penyakit inflamasi kronis pada saluran pencernaan, terutama meliputi penyakit Crohn dan kolitis ulseratif.',
      'treatment': 'Anti-inflamasi (5-ASA), kortikosteroid, imunomodulator, agen biologis, dan pada kasus tertentu pembedahan.',
      'icon': 'exclamationmark_shield',
    },
    'Penyakit Crohn': {
      'description': 'Penyakit inflamasi kronis yang dapat memengaruhi seluruh saluran pencernaan dari mulut hingga anus, bersifat transmural.',
      'treatment': 'Kortikosteroid, imunomodulator, agen biologis, antibiotik, dan pembedahan untuk komplikasi atau kasus refrakter.',
      'icon': 'exclamationmark_shield',
    },
    'Kolitis ulseratif': {
      'description': 'Penyakit inflamasi kronis yang memengaruhi lapisan mukosa usus besar (kolon) dan rektum.',
      'treatment': 'Anti-inflamasi (5-ASA), kortikosteroid, imunomodulator, agen biologis, dan kolektomi pada kasus berat atau refrakter.',
      'icon': 'exclamationmark_shield',
    },
    'Gastroenteritis': {
      'description': 'Peradangan pada lambung dan usus, biasanya disebabkan oleh infeksi virus, bakteri, atau parasit.',
      'treatment': 'Rehidrasi, diet ringan, antibiotik untuk kasus bakteri tertentu, dan pengobatan simptomatik.',
      'icon': 'waveform_path',
    },
    'Infeksi usus (oleh bakteri, virus, parasit)': {
      'description': 'Infeksi pada saluran pencernaan yang disebabkan oleh berbagai patogen seperti E. coli, Salmonella, Rotavirus, atau Giardia.',
      'treatment': 'Tergantung penyebab: rehidrasi, antibiotik untuk bakteri, antiparasit untuk infeksi parasit, dan pengobatan simptomatik.',
      'icon': 'waveform_path',
    },
    'SIBO (Small Intestinal Bacterial Overgrowth)': {
      'description': 'Pertumbuhan berlebihan bakteri di usus halus, menyebabkan kembung, diare, dan malabsorpsi.',
      'treatment': 'Antibiotik (rifaximin, neomycin), prokinetik, diet rendah FODMAP, dan penanganan kondisi yang mendasari.',
      'icon': 'waveform_path',
    },
    'Intoleransi laktosa': {
      'description': 'Ketidakmampuan mencerna laktosa (gula susu) akibat defisiensi enzim laktase.',
      'treatment': 'Pembatasan produk susu, penggunaan suplementasi laktase, dan konsumsi produk rendah laktosa.',
      'icon': 'drop',
    },
    'Penyakit Celiac': {
      'description': 'Penyakit autoimun dimana konsumsi gluten menyebabkan kerusakan pada usus halus dan malabsorpsi nutrisi.',
      'treatment': 'Diet bebas gluten seumur hidup, suplementasi vitamin dan mineral sesuai kebutuhan.',
      'icon': 'exclamationmark_shield',
    },
    'Malabsorpsi': {
      'description': 'Gangguan penyerapan nutrisi di usus halus, dapat disebabkan oleh berbagai kondisi seperti penyakit Celiac, IBD, atau pankreatitis kronis.',
      'treatment': 'Pengobatan kondisi yang mendasari, suplementasi nutrisi, dan modifikasi diet.',
      'icon': 'arrow_down_doc',
    },
    'Obstruksi usus': {
      'description': 'Hambatan pada usus halus atau usus besar yang menghalangi pergerakan normal isi usus.',
      'treatment': 'Tergantung penyebab dan tingkat keparahan: perawatan konservatif dengan dekompresisi nasogastrik, atau pembedahan pada kasus berat.',
      'icon': 'exclamationmark_circle',
    },
    'Hernia abdomen': {
      'description': 'Penonjolan organ atau jaringan melalui titik lemah pada dinding perut.',
      'treatment': 'Pada kebanyakan kasus memerlukan pembedahan untuk mengembalikan organ dan memperkuat dinding perut.',
      'icon': 'arrow_up_circle',
    },
    'Divertikulitis': {
      'description': 'Peradangan atau infeksi pada divertikula (kantong kecil yang terbentuk pada dinding usus besar).',
      'treatment': 'Antibiotik, diet rendah serat selama serangan akut, kemudian diet tinggi serat, dan pada kasus komplikasi mungkin diperlukan pembedahan.',
      'icon': 'exclamationmark_shield',
    },
    'Divertikulosis': {
      'description': 'Kondisi dimana terdapat divertikula (kantong kecil) pada dinding usus besar, tetapi tidak mengalami peradangan.',
      'treatment': 'Diet tinggi serat, cairan yang cukup, dan kadang suplemen serat.',
      'icon': 'circle',
    },
    'Kolitis iskemik': {
      'description': 'Peradangan dan cedera pada usus besar akibat berkurangnya aliran darah ke kolon.',
      'treatment': 'Perawatan suportif, antibiotik pada kasus tertentu, dan pada kasus berat atau komplikasi mungkin diperlukan pembedahan.',
      'icon': 'exclamationmark_shield',
    },
    'Megakolon toksik': {
      'description': 'Komplikasi serius berupa dilatasi akut kolon dengan toksisitas sistemik, sering terjadi pada kolitis ulseratif atau infeksi C. difficile.',
      'treatment': 'Perawatan intensif, antibiotik spektrum luas, kortikosteroid pada IBD, dan sering memerlukan kolektomi darurat.',
      'icon': 'exclamationmark_circle_fill',
    },
    'Polip usus': {
      'description': 'Pertumbuhan abnormal pada lapisan usus besar, kebanyakan jinak tetapi beberapa jenis memiliki potensi menjadi kanker.',
      'treatment': 'Pengangkatan secara kolonoskopi, pemantauan berkala, dan pada kasus dengan risiko tinggi mungkin diperlukan pembedahan.',
      'icon': 'circle',
    },
    'Kanker kolorektal': {
      'description': 'Pertumbuhan sel ganas di usus besar (kolon) atau rektum, sering berkembang dari polip adenomatosa.',
      'treatment': 'Tergantung stadium: pembedahan, kemoterapi, radioterapi, terapi target, atau kombinasi dari berbagai pendekatan.',
      'icon': 'exclamationmark_shield_fill',
    },
    'Volvulus': {
      'description': 'Puntiran usus pada porosnya yang menyebabkan obstruksi dan potensial gangguan aliran darah.',
      'treatment': 'Dekompresi endoskopik pada beberapa kasus, namun sering memerlukan intervensi bedah.',
      'icon': 'arrow_circlepath',
    },
    'Invaginasi usus': {
      'description': 'Kondisi dimana satu bagian usus meluncur ke dalam bagian usus di dekatnya, menyebabkan obstruksi.',
      'treatment': 'Pada anak-anak sering dapat diatasi dengan enema barium, namun pada kasus yang tidak berhasil atau pada dewasa biasanya memerlukan pembedahan.',
      'icon': 'arrow_down_circle',
    },
    'Appendisitis (radang usus buntu)': {
      'description': 'Peradangan pada appendiks (usus buntu) yang dapat menyebabkan nyeri perut kanan bawah dan memerlukan pengobatan segera.',
      'treatment': 'Appendektomi (pengangkatan usus buntu) baik secara terbuka atau laparoskopi, antibiotik, dan perawatan suportif.',
      'icon': 'exclamationmark_circle',
    },
    'Fistula enterik': {
      'description': 'Saluran abnormal yang menghubungkan usus dengan organ lain atau dengan permukaan kulit.',
      'treatment': 'Tergantung lokasi dan kompleksitas: pengobatan konservatif dengan nutrisi dan antibiotik, atau intervensi bedah.',
      'icon': 'arrow_up_arrow_down',
    },
    'Hepatitis A': {
      'description': 'Infeksi virus pada hati yang menyebabkan peradangan dan biasanya ditularkan melalui makanan atau air yang terkontaminasi.',
      'treatment': 'Umumnya sembuh sendiri, perawatan suportif dengan istirahat cukup, nutrisi seimbang, dan hidrasi yang adekuat.',
      'icon': 'waveform_path',
    },
    'Hepatitis B': {
      'description': 'Infeksi virus pada hati yang dapat menjadi kronis dan ditularkan melalui darah dan cairan tubuh.',
      'treatment': 'Pada infeksi akut: perawatan suportif. Pada infeksi kronis: antiviral seperti entecavir, tenofovir, atau interferon.',
      'icon': 'waveform_path_ecg',
    },
    'Hepatitis C': {
      'description': 'Infeksi virus pada hati yang sering menjadi kronis dan ditularkan terutama melalui kontak darah.',
      'treatment': 'Terapi antiviral dengan regimen obat antiviral aksi langsung (DAA) yang memiliki tingkat kesembuhan tinggi.',
      'icon': 'waveform_path_ecg',
    },
    'Hepatitis alkoholik': {
      'description': 'Peradangan hati akibat konsumsi alkohol berlebihan, dapat berkembang menjadi sirosis jika berlanjut.',
      'treatment': 'Penghentian konsumsi alkohol, nutrisi adekuat, kortikosteroid atau pentoxifylline pada kasus berat, dan penanganan komplikasi.',
      'icon': 'drop_fill',
    },
    'Hepatitis autoimun': {
      'description': 'Kondisi kronis dimana sistem kekebalan tubuh menyerang sel-sel hati, menyebabkan peradangan dan kerusakan.',
      'treatment': 'Imunosupresan seperti kortikosteroid dan azathioprine untuk menekan respons imun yang berlebihan.',
      'icon': 'exclamationmark_shield',
    },
    'Sirosis hati': {
      'description': 'Kerusakan hati stadium akhir dimana jaringan hati normal digantikan oleh jaringan parut, mengganggu fungsi hati.',
      'treatment': 'Pengobatan penyebab dasar, manajemen komplikasi (asites, varises, ensefalopati), dan pada kasus lanjut transplantasi hati.',
      'icon': 'exclamationmark_shield_fill',
    },
    'Fatty liver disease (NAFLD)': {
      'description': 'Akumulasi lemak dalam sel hati yang tidak terkait konsumsi alkohol, sering dikaitkan dengan obesitas dan resistensi insulin.',
      'treatment': 'Perubahan gaya hidup dengan penurunan berat badan, kontrol diabetes dan dislipidemia, dan aktivitas fisik teratur.',
      'icon': 'drop_fill',
    },
    'Steatohepatitis non-alkoholik (NASH)': {
      'description': 'Bentuk progresif dari NAFLD dengan peradangan dan kerusakan sel hati, yang dapat berkembang menjadi sirosis.',
      'treatment': 'Perubahan gaya hidup, pengobatan untuk resistensi insulin, vitamin E pada kasus tertentu, dan penanganan komplikasi.',
      'icon': 'exclamationmark_shield',
    },
    'Hemokromatosis': {
      'description': 'Penyakit genetik yang menyebabkan penyerapan zat besi berlebihan dan penumpukan di organ tubuh, terutama hati.',
      'treatment': 'Flebotomi (pengambilan darah) secara rutin, pembatasan asupan zat besi, dan pengobatan untuk komplikasi organ.',
      'icon': 'drop_fill',
    },
    'Wilson\'s disease': {
      'description': 'Penyakit genetik langka yang menyebabkan penumpukan tembaga berlebihan di hati, otak, dan organ lain.',
      'treatment': 'Obat pengikat tembaga seperti D-penicillamine atau trientine, zinc untuk mengurangi penyerapan tembaga, dan diet rendah tembaga.',
      'icon': 'exclamationmark_shield',
    },
    'Kanker hati (hepatoseluler karsinoma)': {
      'description': 'Kanker primer yang berasal dari sel hati, sering terjadi pada latar belakang penyakit hati kronis atau sirosis.',
      'treatment': 'Tergantung stadium: reseksi bedah, ablasi, transplantasi hati, kemoembolisasi, terapi sistemik, atau pendekatan multimodal.',
      'icon': 'exclamationmark_shield_fill',
    },
    'Abses hati': {
      'description': 'Kantong berisi nanah di hati akibat infeksi bakteri atau parasit (seperti amuba).',
      'treatment': 'Antibiotik atau antiparasit, drainase perkutan atau bedah, dan penanganan penyebab dasar.',
      'icon': 'exclamationmark_circle',
    },
    'Sindrom Budd-Chiari': {
      'description': 'Penyumbatan vena hepatik yang menghambat aliran darah keluar dari hati, menyebabkan hepatomegali dan asites.',
      'treatment': 'Antikoagulan, trombolisis, angioplasti dengan stenting, TIPS, atau transplantasi hati pada kasus berat.',
      'icon': 'exclamationmark_shield',
    },
    'Kolelitiasis (batu empedu)': {
      'description': 'Pembentukan batu di kandung empedu, biasanya terdiri dari kolesterol atau pigmen bilirubin.',
      'treatment': 'Pada kasus simptomatik: kolesistektomi (pengangkatan kandung empedu) baik secara laparoskopi atau terbuka.',
      'icon': 'circle_fill',
    },
    'Kolesistitis (radang kandung empedu)': {
      'description': 'Peradangan kandung empedu, umumnya disebabkan oleh batu empedu yang menyumbat saluran empedu.',
      'treatment': 'Antibiotik, analgesik, dan kolesistektomi baik segera atau elektif setelah fase akut mereda.',
      'icon': 'exclamationmark_circle',
    },
    'Kolangitis (radang saluran empedu)': {
      'description': 'Infeksi pada saluran empedu, sering akibat obstruksi oleh batu atau striktur, merupakan keadaan darurat medis.',
      'treatment': 'Antibiotik spektrum luas, dekompresesi saluran empedu melalui ERCP atau drainase perkutan, dan penanganan penyebab dasar.',
      'icon': 'exclamationmark_circle_fill',
    },
    'Koledokolitiasis (batu di saluran empedu)': {
      'description': 'Keberadaan batu di saluran empedu umum (common bile duct), dapat menyebabkan obstruksi, ikterus, dan kolangitis.',
      'treatment': 'ERCP dengan sfingterotomi dan ekstraksi batu, atau pada kasus tertentu intervensi bedah.',
      'icon': 'circle_fill',
    },
    'Kanker kandung empedu': {
      'description': 'Pertumbuhan sel ganas di kandung empedu, sering dikaitkan dengan kolelitiasis kronis.',
      'treatment': 'Reseksi bedah radikal pada stadium awal, kemoterapi atau radioterapi untuk penyakit lanjut.',
      'icon': 'exclamationmark_shield_fill',
    },
    'Primary biliary cholangitis': {
      'description': 'Penyakit autoimun kronis yang menyebabkan kerusakan progresif pada saluran empedu intrahepatik.',
      'treatment': 'Asam ursodeoksikolat (UDCA), fibrates pada kasus tertentu, dan transplantasi hati untuk penyakit stadium akhir.',
      'icon': 'exclamationmark_shield',
    },
    'Primary sclerosing cholangitis': {
      'description': 'Penyakit kronis yang menyebabkan peradangan, fibrosis, dan penyempitan saluran empedu intra dan ekstrahepatik.',
      'treatment': 'Manajemen komplikasi, dilatasi endoskopik untuk striktur dominan, dan transplantasi hati untuk penyakit lanjut.',
      'icon': 'exclamationmark_shield',
    },
    'Atresia bilier (biasanya pada bayi)': {
      'description': 'Kelainan bawaan dimana saluran empedu tidak berkembang normal atau mengalami obstruksi, menyebabkan kolestasis pada bayi.',
      'treatment': 'Prosedur Kasai (portoenterostomi) pada usia dini, dan transplantasi hati jika prosedur Kasai tidak berhasil.',
      'icon': 'exclamationmark_shield_fill',
    },
    'Pankreatitis akut': {
      'description': 'Peradangan mendadak pada pankreas, sering disebabkan oleh batu empedu atau konsumsi alkohol berlebihan.',
      'treatment': 'Perawatan suportif (cairan IV, analgesik), puasa, penanganan komplikasi, dan pengobatan penyebab dasar.',
      'icon': 'exclamationmark_circle',
    },
    'Pankreatitis kronis': {
      'description': 'Peradangan pankreas jangka panjang yang menyebabkan kerusakan permanen dan gangguan fungsi eksokrin dan endokrin.',
      'treatment': 'Pengendalian nyeri, terapi enzim pankreas, insulin untuk diabetes, dan pada kasus tertentu intervensi endoskopik atau bedah.',
      'icon': 'exclamationmark_shield',
    },
    'Kanker pankreas': {
      'description': 'Pertumbuhan sel ganas di pankreas, sering terdeteksi pada stadium lanjut dan memiliki prognosis buruk.',
      'treatment': 'Tergantung stadium: reseksi bedah (prosedur Whipple), kemoterapi, radioterapi, atau pendekatan paliatif.',
      'icon': 'exclamationmark_shield_fill',
    },
    'Kista pankreas': {
      'description': 'Kantong berisi cairan di pankreas, dapat berupa pseudokista pasca-pankreatitis atau neoplasma kistik.',
      'treatment': 'Observasi untuk kista kecil, drainase endoskopik atau bedah untuk pseudokista simptomatik, dan reseksi untuk lesi neoplastik.',
      'icon': 'circle',
    },
    'Insufisiensi pankreas eksokrin': {
      'description': 'Ketidakmampuan pankreas menghasilkan enzim pencernaan dalam jumlah cukup, menyebabkan malabsorpsi nutrisi.',
      'treatment': 'Terapi penggantian enzim pankreas, diet tinggi kalori dengan pembatasan lemak pada kasus tertentu, dan vitamin larut lemak.',
      'icon': 'arrow_down_doc',
    },
    'Hemoroid (wasir)': {
      'description': 'Pembengkakan dan peradangan pembuluh darah vena di rektum dan anus.',
      'treatment': 'Pengobatan konservatif dengan perubahan pola makan (tinggi serat), obat topikal, sitz bath, dan pada kasus berat dapat dilakukan prosedur seperti ligasi pita karet, skleroterapi, atau pembedahan.',
      'icon': 'drop_fill',
    },
    'Fisura ani': {
      'description': 'Robekan kecil pada lapisan anus yang menyebabkan nyeri terutama saat buang air besar.',
      'treatment': 'Sitz bath, obat pelumas, obat pelunak feses, krim nitrat atau kalsium channel blocker, dan pada kasus refrakter mungkin memerlukan sfingterotomi lateral.',
      'icon': 'bandage',
    },
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