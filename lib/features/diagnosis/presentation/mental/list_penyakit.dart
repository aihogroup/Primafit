class PenyakitMental {
  // Map untuk informasi tambahan setiap penyakit
  static final Map<String, Map<String, String>> penyakitInfo = {
    'Depresi Mayor': {
      'description': 'Gangguan suasana hati yang ditandai dengan perasaan sedih mendalam, kehilangan minat atau kesenangan, perubahan nafsu makan dan tidur, serta kesulitan berkonsentrasi.',
      'treatment': 'Psikoterapi (terutama terapi kognitif perilaku), obat antidepresan, dan perubahan gaya hidup.',
      'icon': 'heart_slash_fill',
    },
    'Depresi Persisten / Distimia': {
      'description': 'Bentuk depresi kronis dengan intensitas lebih rendah yang berlangsung minimal dua tahun dengan sedikit periode tanpa gejala.',
      'treatment': 'Kombinasi psikoterapi dan antidepresan, perubahan gaya hidup, dan dukungan sosial.',
      'icon': 'heart_slash',
    },
    'Gangguan Bipolar I': {
      'description': 'Ditandai dengan episode mania yang parah (periode energi dan aktivitas yang sangat tinggi) yang beralih dengan episode depresi.',
      'treatment': 'Penstabil mood, antipsikotik, antidepresan dengan pengawasan ketat, psikoterapi, dan edukasi pasien.',
      'icon': 'waveform_path_ecg',
    },
    'Gangguan Bipolar II': {
      'description': 'Ditandai dengan pola episode depresi yang beralih dengan hipomania (mania ringan) tanpa episode mania penuh.',
      'treatment': 'Penstabil mood, antidepresan dengan pengawasan ketat, psikoterapi, dan manajemen gaya hidup.',
      'icon': 'waveform_path',
    },
    'Cyclothymic Disorder': {
      'description': 'Fluktuasi mood kronis dengan periode gejala hipomania dan depresi ringan yang berlangsung minimal dua tahun.',
      'treatment': 'Penstabil mood, psikoterapi, dan perubahan gaya hidup untuk menstabilkan ritme biologis.',
      'icon': 'arrow_up_arrow_down',
    },
    'Seasonal Affective Disorder': {
      'description': 'Tipe depresi yang terjadi pada musim tertentu, biasanya musim dingin dengan cahaya matahari yang terbatas.',
      'treatment': 'Terapi cahaya, antidepresan, vitamin D, terapi kognitif perilaku, dan aktivitas luar ruangan.',
      'icon': 'sun_max',
    },
    'Gangguan Disforik Pramenstruasi': {
      'description': 'Gejala mood yang parah terjadi sebelum menstruasi, termasuk iritabilitas ekstrem, depresi, dan kecemasan.',
      'treatment': 'Antidepresan SSRI, kontrasepsi hormonal, perubahan gaya hidup, suplemen kalsium, dan manajemen stres.',
      'icon': 'calendar_badge_clock',
    },
    'Gangguan Suasana Hati karena Zat / Obat': {
      'description': 'Gangguan mood yang disebabkan oleh efek fisiologis langsung dari obat-obatan, alkohol, atau bahan kimia.',
      'treatment': 'Perawatan untuk ketergantungan zat, antidepresan atau penstabil mood, dan terapi kognitif perilaku.',
      'icon': 'pill_fill',
    },
    'Gangguan Mood karena Kondisi Medis Umum': {
      'description': 'Gangguan mood yang disebabkan oleh penyakit fisik seperti gangguan tiroid, Parkinson, atau stroke.',
      'treatment': 'Pengobatan kondisi medis yang mendasari, antidepresan atau penstabil mood, dan psikoterapi suportif.',
      'icon': 'cross_circle',
    },
    'Gangguan Regulasi Mood Disruptif': {
      'description': 'Ditandai dengan iritabilitas persisten dan ledakan kemarahan yang sering pada anak-anak, terlalu berat untuk usia perkembangannya.',
      'treatment': 'Terapi perilaku, pelatihan keterampilan orang tua, terapi keluarga, dan kadang-kadang obat.',
      'icon': 'exclamationmark_triangle_fill',
    },
    'Gangguan Kecemasan Umum': {
      'description': 'Kekhawatiran berlebihan dan persisten tentang berbagai hal yang sulit dikendalikan.',
      'treatment': 'Terapi kognitif perilaku, obat antiansietas, antidepresan SSRI/SNRI, dan teknik relaksasi.',
      'icon': 'brain',
    },
    'Fobia Spesifik': {
      'description': 'Ketakutan intens dan tidak rasional terhadap objek atau situasi tertentu seperti ketinggian, darah, atau serangga.',
      'treatment': 'Terapi eksposur, desensitisasi sistematis, terapi kognitif perilaku, dan teknik relaksasi.',
      'icon': 'exclamationmark_shield',
    },
    'Fobia Sosial': {
      'description': 'Ketakutan intens akan situasi sosial karena khawatir dinilai, dipermalukan, atau dihina.',
      'treatment': 'Terapi kognitif perilaku, pengobatan antiansietas, antidepresan SSRI, dan latihan keterampilan sosial.',
      'icon': 'person_2_slash',
    },
    'Gangguan Panik': {
      'description': 'Serangan kecemasan berulang yang tiba-tiba dengan gejala fisik seperti jantung berdebar dan kesulitan bernapas.',
      'treatment': 'Terapi kognitif perilaku, antidepresan, benzodiazepine untuk jangka pendek, dan teknik pernapasan.',
      'icon': 'exclamationmark_circle_fill',
    },
    'Agorafobia': {
      'description': 'Ketakutan terhadap tempat atau situasi di mana melarikan diri mungkin sulit atau memalukan, atau pertolongan tidak tersedia jika terjadi serangan panik.',
      'treatment': 'Terapi eksposur, terapi kognitif perilaku, antidepresan SSRI, dan kadang-kadang benzodiazepine.',
      'icon': 'square_slash',
    },
    'Gangguan Kecemasan karena Kondisi Medis': {
      'description': 'Gejala kecemasan yang disebabkan langsung oleh kondisi kesehatan fisik seperti hipertiroidisme atau penyakit jantung.',
      'treatment': 'Pengobatan kondisi medis yang mendasari, antiansietas, dan terapi kognitif perilaku.',
      'icon': 'cross_circle',
    },
    'Gangguan Kecemasan karena Zat / Obat': {
      'description': 'Gejala kecemasan yang disebabkan oleh penggunaan, penyalahgunaan, atau penghentian zat seperti kafein, alkohol, atau obat-obatan.',
      'treatment': 'Detoksifikasi, penghentian zat pemicu, antiansietas jangka pendek, dan terapi kognitif perilaku.',
      'icon': 'pill_fill',
    },
    'Gangguan Attachment Reactive': {
      'description': 'Pola perilaku abnormal dalam konteks sosial, biasanya terjadi pada anak-anak dengan riwayat pengasuhan yang tidak memadai.',
      'treatment': 'Terapi keluarga, terapi bermain, terapi interaksi orang tua-anak, dan lingkungan yang stabil dan penuh kasih sayang.',
      'icon': 'person_2_slash',
    },
    'Selective Mutism': {
      'description': 'Ketidakmampuan berbicara dalam situasi sosial tertentu meskipun mampu berbicara dan memahami bahasa.',
      'treatment': 'Terapi bicara, terapi kognitif perilaku, desensitisasi sistematis, dan kadang-kadang obat antiansietas.',
      'icon': 'mouth_slash',
    },
    'Gangguan Separation Anxiety': {
      'description': 'Ketakutan berlebihan saat berpisah dari figur pengasuh, tidak sesuai dengan usia perkembangan.',
      'treatment': 'Terapi kognitif perilaku, terapi keluarga, terapi eksposur, dan kadang-kadang antidepresan.',
      'icon': 'person_2_slash',
    },
    'Obsessive-Compulsive Disorder': {
      'description': 'Pikiran yang mengganggu dan berulang (obsesi) yang mendorong perilaku repetitif (kompulsi) untuk mengurangi kecemasan.',
      'treatment': 'Terapi eksposur dan pencegahan respon, antidepresan SSRI, dan kadang-kadang antipsikotik.',
      'icon': 'arrow_circlepath',
    },
    'Body Dysmorphic Disorder': {
      'description': 'Preokupasi dengan cacat fisik yang dibayangkan atau dilebih-lebihkan yang menyebabkan distres signifikan.',
      'treatment': 'Terapi kognitif perilaku, antidepresan SSRI, dan terapi penerimaan dan komitmen.',
      'icon': 'person_crop_circle_badge_exclamationmark',
    },
    'Hoarding Disorder': {
      'description': 'Kesulitan membuang atau berpisah dengan barang-barang terlepas dari nilai sebenarnya.',
      'treatment': 'Terapi kognitif perilaku, terapi eksposur, antidepresan SSRI, dan pendekatan bertahap.',
      'icon': 'archivebox_fill',
    },
    'Trichotillomania': {
      'description': 'Dorongan berulang untuk mencabut rambut yang menyebabkan kebotakan dan distres signifikan.',
      'treatment': 'Terapi perilaku, antidepresan, antagonis opioid, dan terapi penerimaan dan komitmen.',
      'icon': 'scissors',
    },
    'Excoriation': {
      'description': 'Dorongan berulang untuk menggaruk atau mencungkil kulit yang menyebabkan kerusakan jaringan.',
      'treatment': 'Terapi kognitif perilaku, antidepresan, antagonis opioid, dan latihan kebiasaan.',
      'icon': 'hand_raised_slash',
    },
    'OCD karena Zat / Medis': {
      'description': 'Gejala obsesif-kompulsif yang disebabkan oleh efek fisiologis langsung dari zat atau kondisi medis.',
      'treatment': 'Pengobatan kondisi yang mendasari, SSRI, dan terapi kognitif perilaku.',
      'icon': 'cross_circle',
    },
    'Gangguan Pikiran Intrusif Non-klasik': {
      'description': 'Pikiran, bayangan, atau dorongan yang tidak diinginkan dan menyebabkan distres tanpa memenuhi kriteria OCD penuh.',
      'treatment': 'Terapi kognitif perilaku, mindfulness, antidepresan, dan terapi metakognitif.',
      'icon': 'brain',
    },
    'Post-Traumatic Stress Disorder': {
      'description': 'Reaksi stress berkepanjangan setelah mengalami atau menyaksikan peristiwa traumatis.',
      'treatment': 'Terapi pemrosesan kognitif, EMDR, antidepresan, prazosine untuk mimpi buruk, dan dukungan sosial.',
      'icon': 'bolt_slash_fill',
    },
    'Acute Stress Disorder': {
      'description': 'Gejala kecemasan, disosiasi, dan PTSD lainnya yang terjadi dalam waktu satu bulan setelah trauma.',
      'treatment': 'Terapi kognitif perilaku berfokus trauma, teknik manajemen stres, dan kadang-kadang obat penenang.',
      'icon': 'bolt_slash',
    },
    'Adjustment Disorder': {
      'description': 'Reaksi emosional atau perilaku maladaptif terhadap stressor yang dapat diidentifikasi.',
      'treatment': 'Psikoterapi suportif, terapi kognitif perilaku, dan kadang-kadang antidepresan atau antiansietas.',
      'icon': 'arrow_up_right',
    },
    'Gangguan Reaksi terhadap Peristiwa Traumatis Masa Kecil': {
      'description': 'Dampak trauma masa kecil yang kompleks terhadap perkembangan emosional dan sosial.',
      'treatment': 'Psikoterapi berorientasi trauma, terapi bermain, terapi keluarga, dan pendekatan multidisiplin.',
      'icon': 'figure_child_circle',
    },
    'Gangguan Disosiasi karena Trauma': {
      'description': 'Perasaan terlepas dari diri sendiri, lingkungan, atau gangguan memori sebagai respons terhadap trauma.',
      'treatment': 'Psikoterapi berorientasi trauma, EMDR, integrasi sensori, dan pendekatan bertahap.',
      'icon': 'person_fill_questionmark',
    },
    'Skizofrenia': {
      'description': 'Gangguan mental parah dengan gangguan dalam pemikiran, persepsi, emosi, dan perilaku.',
      'treatment': 'Antipsikotik, psikoterapi, rehabilitasi psikososial, dan dukungan sosial.',
      'icon': 'brain_head_profile',
    },
    'Skizoafektif': {
      'description': 'Kombinasi gejala skizofrenia dan gangguan mood mayor (bipolar atau depresi).',
      'treatment': 'Antipsikotik, penstabil mood atau antidepresan, psikoterapi, dan keterampilan hidup.',
      'icon': 'waveform_path_ecg',
    },
    'Gangguan Delusional': {
      'description': 'Keyakinan kuat yang tidak masuk akal meskipun ada bukti yang bertentangan, tanpa gejala psikotik lainnya.',
      'treatment': 'Antipsikotik dosis rendah, terapi kognitif, dan pendekatan non-konfrontatif.',
      'icon': 'exclamationmark_triangle',
    },
    'Gangguan Psikotik Singkat': {
      'description': 'Episode psikotik singkat (kurang dari sebulan) yang dipicu oleh stres berat.',
      'treatment': 'Antipsikotik jangka pendek, intervensi krisis, dan terapi suportif.',
      'icon': 'bolt_slash',
    },
    'Gangguan Psikotik Induksi': {
      'description': 'Gangguan psikotik yang didapat setelah paparan dekat dengan orang lain yang memiliki delusi serupa.',
      'treatment': 'Pemisahan dari individu dengan delusi primer, antipsikotik, dan psikoterapi.',
      'icon': 'person_2_fill',
    },
    'Gangguan Psikotik karena Zat': {
      'description': 'Halusinasi, delusi, atau gejala psikotik lainnya yang disebabkan oleh zat atau penarikan zat.',
      'treatment': 'Detoksifikasi, antipsikotik jangka pendek, dan pengobatan ketergantungan zat.',
      'icon': 'pill_fill',
    },
    'Gangguan Psikotik karena Kondisi Medis': {
      'description': 'Gejala psikotik yang disebabkan oleh kondisi medis seperti tumor otak atau demensia.',
      'treatment': 'Pengobatan kondisi medis yang mendasari, antipsikotik, dan perawatan suportif.',
      'icon': 'cross_circle',
    },
    'Kepribadian Ambang': {
      'description': 'Pola ketidakstabilan dalam hubungan, citra diri, emosi, dan impulsivitas yang signifikan.',
      'treatment': 'Terapi dialektik perilaku, terapi berbasis mentalisasi, kadang-kadang penstabil mood atau antidepresan.',
      'icon': 'arrow_up_arrow_down_circle',
    },
    'Kepribadian Narsistik': {
      'description': 'Pola grandiosity, kebutuhan akan kekaguman, dan kurangnya empati.',
      'treatment': 'Psikoterapi jangka panjang, terapi berbasis mentalisasi, dan pendekatan psikoterapeutik integratif.',
      'icon': 'person_text_rectangle',
    },
    'Kepribadian Antisosial': {
      'description': 'Pola pengabaian dan pelanggaran hak orang lain, kurangnya empati, dan impulsivitas.',
      'treatment': 'Terapi kognitif perilaku, terapi skema, dan kadang-kadang pengobatan untuk komorbiditas.',
      'icon': 'person_slash',
    },
    'Kepribadian Paranoid': {
      'description': 'Pola ketidakpercayaan dan kecurigaan yang meluas di mana motif orang lain ditafsirkan sebagai berbahaya.',
      'treatment': 'Psikoterapi suportif, terapi kognitif, dan kadang-kadang antipsikotik dosis rendah.',
      'icon': 'eye_slash',
    },
    'Kepribadian Skizotipal': {
      'description': 'Pola ketidaknyamanan akut dalam hubungan dekat, distorsi kognitif, dan eksentrisitas perilaku.',
      'treatment': 'Terapi kognitif perilaku, keterampilan sosial, dan kadang-kadang antipsikotik dosis rendah.',
      'icon': 'person_fill_questionmark',
    },
    'Kepribadian Skizoid': {
      'description': 'Pola penarikan diri dari hubungan sosial dan ekspresi emosional yang terbatas.',
      'treatment': 'Psikoterapi supportif, pendekatan bertahap untuk interaksi sosial, dan terapi kelompok.',
      'icon': 'person_fill_xmark',
    },
    'Kepribadian Obsesif-Kompulsif': {
      'description': 'Pola preokupasi dengan ketertiban, kesempurnaan, dan kontrol mental dan interpersonal.',
      'treatment': 'Terapi kognitif perilaku, terapi penerimaan dan komitmen, dan teknik mindfulness.',
      'icon': 'checklist',
    },
    'Kepribadian Menghindar': {
      'description': 'Pola inhibisi sosial, perasaan tidak adekuat, dan hipersensitivitas terhadap evaluasi negatif.',
      'treatment': 'Terapi kognitif perilaku, eksposur bertahap, dan latihan keterampilan sosial.',
      'icon': 'arrow_uturn_backward_circle',
    },
    'Kepribadian Dependen': {
      'description': 'Pola kebutuhan berlebihan untuk dirawat yang menyebabkan perilaku submisif dan ketakutan akan perpisahan.',
      'treatment': 'Terapi asertivitas, terapi kognitif perilaku, dan pembangunan kemandirian bertahap.',
      'icon': 'hand_raised',
    },
    'Kepribadian Histrionik': {
      'description': 'Pola emosi yang berlebihan dan pencarian perhatian.',
      'treatment': 'Psikoterapi wawasan, terapi kognitif, dan latihan regulasi emosi.',
      'icon': 'theatermasks_fill',
    },
    'Attention-Deficit/Hyperactivity Disorder': {
      'description': 'Pola ketidakperhatian persisten dan/atau hiperaktivitas-impulsivitas yang mengganggu fungsi atau perkembangan.',
      'treatment': 'Stimulan atau non-stimulan, terapi perilaku, strategi organisasi, dan penyesuaian lingkungan.',
      'icon': 'bolt',
    },
    'Autism Spectrum Disorder': {
      'description': 'Gangguan perkembangan saraf ditandai dengan kesulitan komunikasi sosial dan pola perilaku terbatas dan berulang.',
      'treatment': 'Terapi perilaku (ABA), terapi bicara dan bahasa, terapi okupasi, dan intervensi pendidikan.',
      'icon': 'puzzlepiece_fill',
    },
    'Gangguan Belajar Spesifik': {
      'description': 'Kesulitan dengan keterampilan akademik tertentu (membaca, matematika, atau ekspresi tertulis) meskipun kecerdasan normal.',
      'treatment': 'Strategi pendidikan khusus, pengajaran terstruktur, akomodasi kelas, dan intervensi berbasis keterampilan.',
      'icon': 'book_fill',
    },
    'Gangguan Komunikasi Sosial': {
      'description': 'Kesulitan dengan komunikasi sosial verbal dan non-verbal tanpa pola perilaku berulang ASD.',
      'treatment': 'Terapi bicara dan bahasa, intervensi pragmatik sosial, dan program keterampilan sosial.',
      'icon': 'bubble_left_bubble_right_fill',
    },
    'Gangguan Koordinasi Motorik': {
      'description': 'Kesulitan dengan koordinasi motorik yang mengganggu aktivitas kehidupan sehari-hari dan akademik.',
      'treatment': 'Terapi okupasi, fisioterapi, adaptasi kegiatan, dan latihan motorik terarah.',
      'icon': 'hand_raised',
    },
    'Gangguan Tic': {
      'description': 'Gerakan atau suara mendadak, cepat, dan berulang yang tidak disengaja (termasuk sindrom Tourette).',
      'treatment': 'Terapi perilaku komprehensif untuk tic, antipsikotik, alpha-adrenergics, dan manajemen stres.',
      'icon': 'arrow_up_right_and_arrow_down_left_rectangle',
    },
    'Anoreksia Nervosa': {
      'description': 'Pembatasan asupan energi yang menyebabkan berat badan rendah abnormal, ketakutan intens bertambah berat, dan gangguan citra tubuh.',
      'treatment': 'Rehabilitasi nutrisi, terapi kognitif perilaku, terapi keluarga, dan kadang-kadang pengobatan.',
      'icon': 'scalemass_fill',
    },
    'Bulimia Nervosa': {
      'description': 'Episode makan berlebihan berulang dengan perilaku kompensasi tidak tepat untuk mencegah kenaikan berat badan.',
      'treatment': 'Terapi kognitif perilaku, antidepresan SSRI, terapi interpersonal, dan pemantauan nutrisi.',
      'icon': 'arrow_up_arrow_down_circle',
    },
    'Binge-Eating Disorder': {
      'description': 'Episode makan berlebihan berulang tanpa perilaku kompensasi bulimik, disertai distres yang signifikan.',
      'treatment': 'Terapi kognitif perilaku, terapi berbasis mindfulness, psikoterapi interpersonal, dan kadang-kadang SSRI.',
      'icon': 'fork_knife',
    },
    'Avoidant/Restrictive Food Intake Disorder': {
      'description': 'Gangguan makan atau asupan makanan yang menyebabkan kegagalan memenuhi kebutuhan nutrisi, tidak terkait dengan citra tubuh.',
      'treatment': 'Terapi paparan makanan bertahap, terapi perilaku, terapi keluarga, dan pengelolaan kecemasan.',
      'icon': 'xmark_circle',
    },
    'Pica': {
      'description': 'Mengonsumsi bahan non-nutrisi seperti tanah, cat, atau kertas selama minimal satu bulan.',
      'treatment': 'Terapi perilaku, intervensi nutrisi, pengobatan kondisi yang mendasari, dan manajemen lingkungan.',
      'icon': 'mouth',
    },
    'Rumination Disorder': {
      'description': 'Pengeluaran kembali makanan yang sudah tertelan secara berulang, yang kemudian dikunyah kembali, ditelan kembali, atau dibuang.',
      'treatment': 'Terapi perilaku, teknik diafragmatik, terapi okupasi, dan manajemen stres.',
      'icon': 'arrow_up_arrow_down',
    },
    'Delirium': {
      'description': 'Gangguan kesadaran dan perhatian akut yang berfluktuasi dengan perubahan kognisi.',
      'treatment': 'Pengobatan penyebab yang mendasari, obat-obatan untuk gejala perilaku jika perlu, dan modifikasi lingkungan.',
      'icon': 'brain',
    },
    'Demensia Alzheimer': {
      'description': 'Penyakit neurodegeneratif progresif yang menyebabkan masalah memori, berpikir, dan perilaku.',
      'treatment': 'Inhibitor kolinesterase, memantine, terapi kognitif, dan perawatan suportif.',
      'icon': 'brain',
    },
    'Demensia Frontotemporal': {
      'description': 'Penyakit neurodegeneratif yang memengaruhi lobus frontal dan temporal otak, menyebabkan perubahan kepribadian dan bahasa.',
      'treatment': 'Manajemen gejala perilaku, terapi wicara, dan perawatan suportif komprehensif.',
      'icon': 'brain_fill',
    },
    'Demensia Vaskular': {
      'description': 'Gangguan kognitif akibat masalah aliran darah ke otak, seperti stroke atau penyakit pembuluh darah kecil.',
      'treatment': 'Manajemen faktor risiko vaskular, obat-obatan untuk melindungi syaraf, dan rehabilitasi kognitif.',
      'icon': 'brain',
    },
    'Gangguan Neurokognitif Ringan': {
      'description': 'Penurunan kognitif ringan yang tidak mengganggu kemandirian dalam aktivitas sehari-hari.',
      'treatment': 'Stimulasi kognitif, modifikasi gaya hidup, pengobatan kondisi yang mendasari, dan pemantauan.',
      'icon': 'brain',
    },
    'Gangguan Kognitif karena Cedera Kepala': {
      'description': 'Defisit kognitif akibat trauma otak seperti kebingungan, masalah memori, dan perubahan kepribadian.',
      'treatment': 'Rehabilitasi kognitif, terapi fisik, terapi okupasi, dan manajemen gejala.',
      'icon': 'brain_head_profile',
    },
    'Gangguan Identitas Gender': {
      'description': 'Ketidaksesuaian antara gender yang dirasakan/diekspresikan dan gender yang ditugaskan saat lahir.',
      'treatment': 'Konseling, dukungan sosial, terapi hormon pada beberapa kasus, dan pilihan pembedahan.',
      'icon': 'person_2',
    },
    'Gangguan Tidur terkait Kesehatan Mental': {
      'description': 'Masalah tidur yang terkait dengan kondisi kesehatan mental seperti insomnia, hipersomnia, atau parasomnia.',
      'treatment': 'Higiene tidur, terapi kognitif perilaku untuk insomnia, relaksasi, dan kadang-kadang obat tidur.',
      'icon': 'bed_double_fill',
    },
    'Gangguan Somatisasi': {
      'description': 'Keluhan fisik berulang yang tidak dapat dijelaskan secara medis dan terkait dengan distres psikologis.',
      'treatment': 'Terapi kognitif perilaku, manajemen stres, antidepresan, dan perawatan terintegrasi.',
      'icon': 'person_fill_viewfinder',
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