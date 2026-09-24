class PenyakitKulit {
  // Map untuk informasi tambahan setiap penyakit
  static final Map<String, Map<String, String>> penyakitInfo = {
    'Acne Vulgaris': {
      'description': 'Kondisi kulit yang terjadi ketika folikel rambut tersumbat oleh minyak dan sel kulit mati.',
      'treatment': 'Benzoil peroksida, retinoid, antibiotik topikal, dan perawatan kulit teratur.',
      'icon': 'face_retouching_natural',
    },
    'Psoriasis': {
      'description': 'Penyakit autoimun yang menyebabkan percepatan siklus pertumbuhan sel kulit, menghasilkan penumpukan sel kulit.',
      'treatment': 'Kortikosteroid topikal, terapi cahaya, obat biologis, dan pelembab.',
      'icon': 'healing',
    },
    'Dermatitis Atopik (Eczema)': {
      'description': 'Kondisi kulit kronis yang menyebabkan kulit kering, gatal, dan meradang.',
      'treatment': 'Pelembab rutin, kortikosteroid topikal, dan penghindaran pemicu.',
      'icon': 'health_and_safety',
    },
    'Seborrheic Dermatitis': {
      'description': 'Kondisi kulit yang menyebabkan kulit berminyak, bersisik, dan meradang, terutama di kulit kepala.',
      'treatment': 'Sampo antijamur, kortikosteroid topikal, dan perawatan kulit reguler.',
      'icon': 'spa',
    },
    'Rosacea': {
      'description': 'Kondisi kulit kronis yang menyebabkan kemerahan dan tampak pembuluh darah di wajah.',
      'treatment': 'Antibiotik topikal dan oral, penggunaan tabir surya, dan hindari pemicu.',
      'icon': 'face',
    },
    'Tinea (Infeksi Jamur)': {
      'description': 'Infeksi jamur pada kulit yang dapat mempengaruhi berbagai bagian tubuh.',
      'treatment': 'Antijamur topikal atau oral, menjaga kulit tetap kering, dan kebersihan.',
      'icon': 'coronavirus',
    },
    'Ringworm (Tinea Corporis)': {
      'description': 'Infeksi jamur pada kulit yang menyebabkan ruam melingkar dan gatal.',
      'treatment': 'Antijamur topikal, kebersihan pribadi yang baik, dan mencegah berbagi barang pribadi.',
      'icon': 'coronavirus',
    },
    'Athlete\'s Foot (Tinea Pedis)': {
      'description': 'Infeksi jamur yang mempengaruhi kaki, terutama antara jari-jari kaki dan telapak kaki.',
      'treatment': 'Antijamur topikal, menjaga kaki tetap kering, dan alas kaki yang tepat.',
      'icon': 'coronavirus',
    },
    'Impetigo': {
      'description': 'Infeksi kulit bakteri yang sangat menular, terutama mempengaruhi anak-anak.',
      'treatment': 'Antibiotik topikal atau oral, dan pembersihan area yang terinfeksi.',
      'icon': 'medical_services',
    },
    'Lichen Planus': {
      'description': 'Peradangan kulit dan mukosa yang menyebabkan ruam gatal dan bersisik.',
      'treatment': 'Kortikosteroid, antihistamin, dan retinoid untuk kasus yang parah.',
      'icon': 'healing',
    },
    'Vitiligo': {
      'description': 'Hilangnya pigmen kulit di area tertentu, menyebabkan bercak putih.',
      'treatment': 'Kortikosteroid topikal, terapi cahaya, dan transplantasi kulit untuk kasus yang parah.',
      'icon': 'palette',
    },
    'Hives (Urticaria)': {
      'description': 'Reaksi kulit yang ditandai dengan benjolan merah, gatal, dan bengkak.',
      'treatment': 'Antihistamin, menghindari pemicu, dan kortikosteroid untuk kasus yang parah.',
      'icon': 'health_and_safety',
    },
    'Contact Dermatitis': {
      'description': 'Reaksi kulit yang terjadi ketika kulit bersentuhan dengan zat yang menyebabkan iritasi atau alergi.',
      'treatment': 'Menghindari pemicu, kortikosteroid topikal, dan antihistamin untuk gatal.',
      'icon': 'health_and_safety',
    },
    'Shingles (Herpes Zoster)': {
      'description': 'Infeksi virus yang menyebabkan ruam nyeri, biasanya di satu sisi tubuh.',
      'treatment': 'Antiviral, analgesik, dan pada beberapa kasus kortikosteroid.',
      'icon': 'coronavirus',
    },
    'Chickenpox (Varicella)': {
      'description': 'Infeksi virus yang menyebabkan ruam gatal dan lesi berisi cairan.',
      'treatment': 'Pengobatan simptomatik, antiviral untuk kasus parah.',
      'icon': 'coronavirus',
    },
    'Cold Sores (Herpes Simplex Virus)': {
      'description': 'Infeksi yang menyebabkan lepuh berisi cairan, biasanya di sekitar mulut.',
      'treatment': 'Antiviral topikal dan oral, perawatan simptomatik.',
      'icon': 'coronavirus',
    },
    'Molluscum Contagiosum': {
      'description': 'Infeksi virus kulit yang menyebabkan benjolan kecil berkilau dengan cekungan di tengahnya.',
      'treatment': 'Seringkali sembuh sendiri, krioterapi, penggunaan asam salisilat atau prosedur kuretase.',
      'icon': 'coronavirus',
    },
    'Scabies (Gatal-gatal)': {
      'description': 'Infestasi kulit oleh tungau kecil yang menyebabkan gatal intens, terutama di malam hari.',
      'treatment': 'Krim permethrin, ivermectin oral, dan mencuci semua pakaian dan seprai.',
      'icon': 'coronavirus',
    },
    'Psoriatic Arthritis': {
      'description': 'Bentuk artritis yang mempengaruhi beberapa orang dengan psoriasis, menyebabkan peradangan sendi.',
      'treatment': 'Obat anti-inflamasi, obat antireumatik, dan terapi biologis.',
      'icon': 'accessibility',
    },
    'Keloids': {
      'description': 'Pertumbuhan jaringan parut yang berlebihan di tempat cedera kulit.',
      'treatment': 'Suntikan kortikosteroid, radioterapi, atau pembedahan untuk kasus parah.',
      'icon': 'healing',
    },
    'Skin Cancer (Kanker Kulit)': {
      'description': 'Pertumbuhan abnormal sel-sel kulit, sering disebabkan oleh paparan sinar UV.',
      'treatment': 'Pembedahan, radioterapi, kemoterapi, atau terapi biologis tergantung pada jenis dan stadium.',
      'icon': 'dangerous',
    },
    'Basal Cell Carcinoma': {
      'description': 'Jenis kanker kulit yang paling umum, biasanya tumbuh lambat dan jarang menyebar.',
      'treatment': 'Pembedahan, radiasi, atau krim topikal tertentu.',
      'icon': 'dangerous',
    },
    'Squamous Cell Carcinoma': {
      'description': 'Kanker kulit yang terbentuk di sel skuamosa dan dapat menyebar ke jaringan sekitar.',
      'treatment': 'Eksisi bedah, radioterapi, atau terapi fotodinamik.',
      'icon': 'dangerous',
    },
    'Melanoma': {
      'description': 'Bentuk kanker kulit yang paling berbahaya, berasal dari sel-sel penghasil melanin.',
      'treatment': 'Pembedahan, imunoterapi, radioterapi, atau kemoterapi tergantung stadium.',
      'icon': 'dangerous',
    },
    'Acne Rosacea': {
      'description': 'Kondisi kulit yang menyebabkan kemerahan dan tampak pembuluh darah di wajah, sering disertai jerawat.',
      'treatment': 'Antibiotik topikal dan oral, hindari pemicu, dan perawatan laser untuk pembuluh darah yang terlihat.',
      'icon': 'face',
    },
    'Actinic Keratosis': {
      'description': 'Pertumbuhan prakanker yang disebabkan oleh paparan sinar matahari yang berlebihan.',
      'treatment': 'Krioterapi, krim topikal, atau terapi fotodinamik.',
      'icon': 'wb_sunny',
    },
    'Xerosis': {
      'description': 'Kondisi kulit kering yang dapat menyebabkan gatal, retak, dan kadang-kadang berdarah.',
      'treatment': 'Pelembab rutin, hindari sabun keras, dan minum cukup air.',
      'icon': 'invert_colors_off',
    },
    'Alopecia Areata': {
      'description': 'Kondisi autoimun yang menyebabkan kebotakan di area tertentu.',
      'treatment': 'Kortikosteroid topikal atau suntikan, minoxidil, atau imunoterapi.',
      'icon': 'content_cut',
    },
    'Telogen Effluvium': {
      'description': 'Kerontokan rambut sementara yang disebabkan oleh perubahan dalam siklus pertumbuhan rambut.',
      'treatment': 'Mengatasi penyebab yang mendasari, suplemen nutrisi, dan manajemen stres.',
      'icon': 'content_cut',
    },
    'Trichotillomania': {
      'description': 'Gangguan mental yang ditandai dengan dorongan untuk mencabut rambut sendiri.',
      'treatment': 'Terapi perilaku kognitif, obat-obatan untuk kecemasan atau OCD, dan dukungan psikologis.',
      'icon': 'psychology',
    },
    'Lupus': {
      'description': 'Penyakit autoimun yang dapat mempengaruhi berbagai organ termasuk kulit, menyebabkan ruam khas.',
      'treatment': 'Obat anti-inflamasi, imunosupresan, dan pelindung matahari.',
      'icon': 'health_and_safety',
    },
    'Erythema Multiforme': {
      'description': 'Reaksi kulit yang ditandai dengan lesi berbentuk target, sering dipicu oleh infeksi atau obat-obatan.',
      'treatment': 'Pengobatan penyebab, kortikosteroid, dan antihistamin.',
      'icon': 'healing',
    },
    'Pityriasis Rosea': {
      'description': 'Ruam kulit yang dimulai dengan bercak tunggal besar diikuti dengan bercak kecil, terutama di batang tubuh.',
      'treatment': 'Biasanya sembuh sendiri, antihistamin untuk gatal, dan terapi UV untuk kasus yang parah.',
      'icon': 'healing',
    },
    'Fungal Nail Infection (Onychomycosis)': {
      'description': 'Infeksi jamur yang mempengaruhi kuku, menyebabkannya menebal, berubah warna, dan kadang-kadang pecah.',
      'treatment': 'Antijamur oral atau topikal, pada kasus parah mungkin memerlukan pengangkatan kuku.',
      'icon': 'coronavirus',
    },
    'Candidiasis': {
      'description': 'Infeksi jamur Candida yang dapat mempengaruhi mulut, kerongkongan, kulit, atau area genital.',
      'treatment': 'Antijamur topikal atau oral, dan menjaga area yang terkena tetap kering dan bersih.',
      'icon': 'coronavirus',
    },
    'Seborrheic Keratosis': {
      'description': 'Pertumbuhan jinak pada kulit yang tampak seperti tempelan berminyak dan berwarna.',
      'treatment': 'Biasanya tidak memerlukan pengobatan kecuali untuk alasan kosmetik, dapat diangkat dengan krioterapi atau kuretase.',
      'icon': 'healing',
    },
    'Warts (Kutil)': {
      'description': 'Pertumbuhan kulit yang disebabkan oleh virus HPV, yang dapat muncul di mana saja di tubuh.',
      'treatment': 'Krioterapi, elektrokauterisasi, asam salisilat, atau pengobatan laser.',
      'icon': 'coronavirus',
    },
    'Miliaria (Panas Dalam)': {
      'description': 'Ruam kulit akibat panas yang terjadi ketika keringat terperangkap di bawah kulit.',
      'treatment': 'Mendinginkan kulit, menghindari panas berlebihan, dan menjaga kulit tetap kering.',
      'icon': 'thermostat',
    },
    'Pachyonychia Congenita': {
      'description': 'Kelainan genetik langka yang mempengaruhi kuku dan kadang-kadang kulit.',
      'treatment': 'Pengobatan simptomatik, perawatan kuku khusus, dan pengobatan untuk nyeri.',
      'icon': 'accessibility',
    },
    'Keratosis Pilaris': {
      'description': 'Kondisi kulit umum yang menyebabkan benjolan kecil dan kasar pada kulit, seperti "kulit ayam".',
      'treatment': 'Pelembab, krim yang mengandung asam alfa hidroksi, atau retinoid topikal.',
      'icon': 'healing',
    },
    'Hidradenitis Suppurativa': {
      'description': 'Penyakit kulit kronis yang menyebabkan benjolan nyeri di bawah kulit, terutama di area dengan kelenjar keringat.',
      'treatment': 'Antibiotik, anti-inflamasi, terapi biologis, dan kadang-kadang pembedahan.',
      'icon': 'health_and_safety',
    },
    'Angioma': {
      'description': 'Pertumbuhan jinak yang terdiri dari pembuluh darah kecil yang berkumpul di permukaan kulit.',
      'treatment': 'Seringkali tidak memerlukan pengobatan kecuali untuk alasan kosmetik, dapat dihilangkan dengan laser atau elektrokauter.',
      'icon': 'healing',
    },
    'Erythema Nodosum': {
      'description': 'Peradangan jaringan lemak di bawah kulit yang menyebabkan benjolan merah nyeri, terutama di kaki.',
      'treatment': 'Pengobatan kondisi yang mendasari, NSAID, dan istirahat.',
      'icon': 'healing',
    },
    'Dermatofibroma': {
      'description': 'Pertumbuhan jinak pada kulit yang terbentuk setelah cedera kecil, tampak seperti benjolan keras berwarna coklat.',
      'treatment': 'Biasanya tidak memerlukan pengobatan, dapat diangkat secara bedah jika mengganggu.',
      'icon': 'healing',
    },
    'Lichen Sclerosus': {
      'description': 'Kondisi kulit langka yang menyebabkan bercak putih tipis, sering mempengaruhi area genital.',
      'treatment': 'Kortikosteroid topikal potent, dan pemantauan rutin untuk perubahan kanker.',
      'icon': 'healing',
    },
    'Basanofilaria': {
      'description': 'Jenis tumor kulit yang sangat jarang dengan tingkat kekambuhan yang tinggi.',
      'treatment': 'Eksisi bedah, kadang-kadang diikuti dengan radioterapi untuk kasus yang agresif.',
      'icon': 'dangerous',
    },
    'Chilblains': {
      'description': 'Peradangan kulit kecil yang menyakitkan akibat paparan dingin yang berkepanjangan.',
      'treatment': 'Menghangatkan area yang terkena secara perlahan, krim untuk meningkatkan sirkulasi, dan melindungi dari dingin.',
      'icon': 'ac_unit',
    },
    'Prurigo Nodularis': {
      'description': 'Kondisi kulit kronis yang ditandai dengan benjolan sangat gatal dan kasar pada kulit.',
      'treatment': 'Kortikosteroid topikal potent, antihistamin, fototerapi, dan obat imunosupresan.',
      'icon': 'healing',
    },
    'Pachydermoperiostosis': {
      'description': 'Gangguan genetik langka yang menyebabkan penebalan kulit dan tulang, terutama di wajah dan ekstremitas.',
      'treatment': 'Pengobatan simptomatik, NSAID untuk nyeri sendi, dan kadang pembedahan untuk masalah kosmetik.',
      'icon': 'accessibility',
    },
    'Hyperhidrosis': {
      'description': 'Kondisi yang menyebabkan keringat berlebih, terutama di telapak tangan, kaki, dan ketiak.',
      'treatment': 'Antiperspiran kuat, iontoforesis, suntikan botox, atau pembedahan untuk kasus parah.',
      'icon': 'water_drop',
    },
    'Darier\'s Disease': {
      'description': 'Gangguan genetik yang menyebabkan bercak berminyak dan berkerak, terutama di area seborrhea.',
      'treatment': 'Retinoid oral, antibiotik topikal untuk infeksi sekunder, dan perawatan kulit yang baik.',
      'icon': 'accessibility',
    },
    'Scleroderma': {
      'description': 'Penyakit autoimun yang menyebabkan penebalan dan pengerasan kulit serta jaringan ikat.',
      'treatment': 'Pengobatan simptomatik, imunosupresan, dan terapi fisik.',
      'icon': 'accessibility',
    },
    'Acrodermatitis': {
      'description': 'Kelompok gangguan kulit yang mempengaruhi ekstremitas, sering terkait dengan defisiensi nutrisi.',
      'treatment': 'Mengatasi penyebab yang mendasari, suplemen zinc untuk beberapa jenis, dan perawatan kulit.',
      'icon': 'healing',
    },
    'Pityriasis Versicolor': {
      'description': 'Infeksi jamur pada kulit yang menyebabkan bercak dengan warna yang berbeda dari kulit sekitarnya.',
      'treatment': 'Antijamur topikal atau oral, sampo selenium, dan mencegah kekambuhan dengan perawatan pemeliharaan.',
      'icon': 'coronavirus',
    },
    'Lupus Erythematosus': {
      'description': 'Penyakit autoimun yang dapat mempengaruhi kulit, sendi, dan organ dalam, dengan ruam khas berbentuk kupu-kupu di wajah.',
      'treatment': 'Obat anti-malaria, kortikosteroid, imunosupresan, dan perlindungan dari sinar matahari.',
      'icon': 'health_and_safety',
    },
    'Eczema Herpeticum': {
      'description': 'Infeksi virus herpes simplex yang terjadi pada kulit yang sudah terkena eksim.',
      'treatment': 'Antiviral sistemik seperti acyclovir, dan perawatan untuk eksim yang mendasari.',
      'icon': 'coronavirus',
    },
    'Tinea Versicolor': {
      'description': 'Infeksi jamur kulit yang menyebabkan bercak berwarna lebih terang atau lebih gelap dari kulit sekitarnya.',
      'treatment': 'Antijamur topikal atau oral, sampo selenium, dan pencegahan kekambuhan.',
      'icon': 'coronavirus',
    },
    'Pachyderma': {
      'description': 'Penebalan kulit abnormal yang dapat terjadi sebagai respons terhadap berbagai kondisi.',
      'treatment': 'Pengobatan kondisi yang mendasari, keratolisis, dan kadang kortikosteroid.',
      'icon': 'healing',
    },
    'Keloid Scarring': {
      'description': 'Jaringan parut yang tumbuh melebihi batas luka asli, membentuk massa keras dan terangkat.',
      'treatment': 'Suntikan kortikosteroid, terapi tekanan, cryotherapy, atau pembedahan untuk kasus parah.',
      'icon': 'healing',
    },
    'Nodul Lymphoma': {
      'description': 'Pertumbuhan abnormal sel limfosit di kulit, merupakan tanda dari limfoma kulit.',
      'treatment': 'Tergantung jenis dan stadium: kemoterapi, radioterapi, atau terapi target.',
      'icon': 'dangerous',
    },
    'Syringoma': {
      'description': 'Tumor jinak yang berasal dari kelenjar keringat, biasanya muncul sebagai benjolan kecil di bawah mata.',
      'treatment': 'Perawatan kosmetik termasuk elektrolisis, laser, atau eksisi untuk alasan kosmetik.',
      'icon': 'healing',
    },
    'Lichen Simplex Chronicus': {
      'description': 'Kondisi kulit yang disebabkan oleh garukan berulang, menghasilkan area kulit menebal dan terasa gatal.',
      'treatment': 'Kortikosteroid topikal, antihistamin, dan menghentikan siklus gatal-garuk.',
      'icon': 'healing',
    },
    'Erythema Ab Igne': {
      'description': 'Perubahan pigmentasi kulit yang disebabkan oleh paparan panas berulang, membentuk pola seperti jaring.',
      'treatment': 'Menghilangkan sumber panas, dan perawatan laser untuk perubahan warna.',
      'icon': 'whatshot',
    },
    'Drug Eruption': {
      'description': 'Reaksi kulit yang disebabkan oleh obat-obatan, dapat bervariasi dari ruam ringan hingga reaksi yang mengancam jiwa.',
      'treatment': 'Menghentikan obat penyebab, antihistamin, kortikosteroid, atau perawatan intensif untuk kasus parah.',
      'icon': 'medication',
    },
    'Wegener\'s Granulomatosis': {
      'description': 'Penyakit autoimun langka yang menyebabkan peradangan pembuluh darah dan dapat mempengaruhi kulit.',
      'treatment': 'Imunosupresan, kortikosteroid, dan terapi target biologis.',
      'icon': 'health_and_safety',
    },
    'Guttate Psoriasis': {
      'description': 'Bentuk psoriasis yang ditandai dengan bercak kecil berbentuk tetesan, sering muncul setelah infeksi streptokokus.',
      'treatment': 'Terapi UV, kortikosteroid topikal, dan pengobatan infeksi yang mendasari.',
      'icon': 'healing',
    },
    'Perioral Dermatitis': {
      'description': 'Ruam kulit di sekitar mulut yang dapat menyerupai jerawat atau rosasea.',
      'treatment': 'Antibiotik topikal atau oral, menghindari kortikosteroid, dan perawatan kulit lembut.',
      'icon': 'face',
    },
    'Sweet\'s Syndrome': {
      'description': 'Kondisi kulit langka yang ditandai dengan demam dan lesi kulit nyeri yang muncul tiba-tiba.',
      'treatment': 'Kortikosteroid, kolkisin, dan pengobatan penyakit yang mendasari jika ada.',
      'icon': 'healing',
    },
    'Berylliosis': {
      'description': 'Penyakit paru-paru dan kulit yang disebabkan oleh paparan berilium, dapat menyebabkan granuloma pada kulit.',
      'treatment': 'Menghindari lebih banyak paparan berilium, kortikosteroid, dan penanganan simptomatik.',
      'icon': 'health_and_safety',
    },
    'Granuloma Annulare': {
      'description': 'Kondisi kulit yang menyebabkan benjolan melingkar berwarna merah atau daging.',
      'treatment': 'Seringkali tidak memerlukan pengobatan, kortikosteroid topikal atau injeksi untuk kasus yang parah.',
      'icon': 'healing',
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