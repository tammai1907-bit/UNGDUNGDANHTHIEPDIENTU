import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/business_card_model.dart';
import '../models/saved_contact_model.dart';
import '../models/analytics_model.dart';
import '../config/app_constants.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('digital_business_card.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.delete('profiles');
      await _insertInitialData(db);
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Bảng lưu danh thiếp của bản thân (Đa hồ sơ - Multi profile)
    await db.execute('''
      CREATE TABLE profiles (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        cardName TEXT NOT NULL,
        fullName TEXT NOT NULL,
        jobTitle TEXT NOT NULL,
        company TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL,
        website TEXT,
        address TEXT,
        bio TEXT,
        avatarUrl TEXT,
        logoUrl TEXT,
        coverUrl TEXT,
        socialLinks TEXT,
        template TEXT,
        themeColorId TEXT,
        skills TEXT,
        portfolioUrl TEXT,
        isDefault INTEGER NOT NULL DEFAULT 0,
        isPrivatePhone INTEGER NOT NULL DEFAULT 0,
        isPrivateEmail INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // 2. Bảng lưu danh thiếp nhận được (Contact Wallet)
    await db.execute('''
      CREATE TABLE saved_contacts (
        id TEXT PRIMARY KEY,
        fullName TEXT NOT NULL,
        jobTitle TEXT,
        company TEXT,
        phone TEXT,
        email TEXT,
        website TEXT,
        address TEXT,
        bio TEXT,
        avatarUrl TEXT,
        socialLinks TEXT,
        tags TEXT,
        notes TEXT,
        latitude REAL,
        longitude REAL,
        locationName TEXT,
        metAt TEXT NOT NULL,
        reminderDate TEXT,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        rawVCard TEXT
      )
    ''');

    // 3. Bảng lưu thống kê tương tác danh thiếp (Analytics)
    await db.execute('''
      CREATE TABLE analytics (
        cardId TEXT PRIMARY KEY,
        totalViews INTEGER NOT NULL DEFAULT 0,
        totalSaves INTEGER NOT NULL DEFAULT 0,
        qrScans INTEGER NOT NULL DEFAULT 0,
        nfcTaps INTEGER NOT NULL DEFAULT 0,
        clickThroughRates TEXT,
        dailyViews TEXT
      )
    ''');

    // Khởi tạo sẵn danh thiếp mẫu để app luôn có dữ liệu sinh động
    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    final now = DateTime.now();
    
    // Thẻ mặc định: Công việc chính thức
    final officialCard = BusinessCardModel(
      id: 'card_official_01',
      userId: 'user_current',
      cardName: 'Công Việc Chính Thức',
      fullName: 'Mai Văn Tâm',
      jobTitle: 'Kỹ sư Phần mềm Cấp cao (Senior Mobile Engineer)',
      company: 'Tập đoàn Công nghệ TechCorp VN',
      phone: '0987654321',
      email: 'tam.mai@techcorp.vn',
      website: 'https://techcorp.vn',
      address: 'Tầng 12, Tòa nhà Innovation, Quận 1, TP. Hồ Chí Minh',
      bio: 'Chuyên gia phát triển ứng dụng di động Flutter & iOS Native với hơn 5 năm kinh nghiệm.',
      socialLinks: {
        'linkedin': 'https://linkedin.com/in/maivantam-dev',
        'github': 'https://github.com/maivantam',
        'facebook': 'https://facebook.com/tam.mai.tech',
        'zalo': 'https://zalo.me/0987654321',
      },
      template: CardTemplateType.modern,
      themeColorId: 'navy_blue',
      skills: ['Flutter', 'Dart', 'Swift', 'RESTful API', 'Clean Architecture', 'CI/CD'],
      portfolioUrl: 'https://maivantam.dev/cv.pdf',
      isDefault: true,
      createdAt: now,
      updatedAt: now,
    );

    // Thẻ thứ 2: Freelance
    final freelanceCard = BusinessCardModel(
      id: 'card_freelance_02',
      userId: 'user_current',
      cardName: 'Dự Án Freelance & Tư Vấn',
      fullName: 'Tâm Mai (Kevin)',
      jobTitle: 'Full-stack Mobile & UI/UX Consultant',
      company: 'Tam Studio Global',
      phone: '0912345678',
      email: 'contact@tamstudio.dev',
      website: 'https://tamstudio.dev',
      address: 'TP. Hồ Chí Minh, Việt Nam (Remote Global)',
      bio: 'Nhận thiết kế & phát triển sản phẩm MVP di động chuẩn App Store/Google Play trong 4 tuần.',
      socialLinks: {
        'linkedin': 'https://linkedin.com/in/tam-mai',
        'github': 'https://github.com/tam-dev',
        'twitter': 'https://x.com/tam_flutter',
      },
      template: CardTemplateType.tech,
      themeColorId: 'royal_purple',
      skills: ['Cross-platform', 'Firebase', 'Figma', 'GraphQL', 'Stripe'],
      portfolioUrl: 'https://tamstudio.dev/portfolio',
      isDefault: false,
      createdAt: now,
      updatedAt: now,
    );

    await db.insert('profiles', officialCard.toMap());
    await db.insert('profiles', freelanceCard.toMap());

    // Tạo sẵn analytics mẫu cho thẻ 1
    final analytics1 = CardAnalyticsModel(
      cardId: officialCard.id,
      totalViews: 142,
      totalSaves: 38,
      qrScans: 85,
      nfcTaps: 57,
      clickThroughRates: {
        'phone': 24,
        'email': 18,
        'linkedin': 45,
        'website': 32,
        'github': 20,
      },
      dailyViews: {
        '10/11': 14,
        '10/12': 21,
        '10/13': 18,
        '10/14': 29,
        '10/15': 25,
        '10/16': 35,
      },
    );
    await db.insert('analytics', analytics1.toMap());

    // Thêm danh thiếp đối tác mẫu vào Ví (Contact Wallet)
    final sampleContact1 = SavedContactModel(
      id: 'contact_01',
      fullName: 'Trần Thị Mai',
      jobTitle: 'Giám đốc Marketing (CMO)',
      company: 'Global Retail JSC',
      phone: '0903123456',
      email: 'mai.tran@globalretail.com',
      website: 'https://globalretail.com',
      address: '702 Nguyễn Văn Linh, Quận 7, TP.HCM',
      bio: 'Kết nối hợp tác chiến dịch quảng cáo và tiếp thị kỹ thuật số.',
      socialLinks: {
        'linkedin': 'https://linkedin.com/in/maitran-cmo',
        'facebook': 'https://facebook.com/mai.tran',
      },
      tags: ['Khách hàng', 'VIP'],
      notes: 'Gặp gỡ tại Hội thảo Vietnam Mobile Day. Cần gửi bản đề xuất giải pháp vào tuần sau.',
      latitude: 10.7297,
      longitude: 106.7219,
      locationName: 'Trung tâm Hội chợ SECC - Quận 7, TP.HCM',
      metAt: now.subtract(const Duration(days: 2)),
      isFavorite: true,
    );

    final sampleContact2 = SavedContactModel(
      id: 'contact_02',
      fullName: 'Lê Hoàng Nam',
      jobTitle: 'Product Manager',
      company: 'Fintech Solutions Ltd.',
      phone: '0938889900',
      email: 'nam.le@fintechvn.com',
      website: 'https://fintechvn.com',
      address: 'Tòa nhà Bitexco, Quận 1, TP.HCM',
      bio: 'Chuyên gia giải pháp cổng thanh toán và Open Banking API.',
      socialLinks: {
        'linkedin': 'https://linkedin.com/in/namle-pm',
        'github': 'https://github.com/namle-fintech',
      },
      tags: ['Đối tác'],
      notes: 'Thảo luận tích hợp cổng thanh toán trực tiếp.',
      latitude: 10.7718,
      longitude: 106.7044,
      locationName: 'Quận 1, TP. Hồ Chí Minh',
      metAt: now.subtract(const Duration(days: 5)),
      isFavorite: false,
    );

    await db.insert('saved_contacts', sampleContact1.toMap());
    await db.insert('saved_contacts', sampleContact2.toMap());
  }

  // ================= PROFILES CRUD ================= //
  Future<List<BusinessCardModel>> getAllProfiles() async {
    final db = await instance.database;
    final result = await db.query('profiles', orderBy: 'isDefault DESC, createdAt DESC');
    return result.map((map) => BusinessCardModel.fromMap(map)).toList();
  }

  Future<BusinessCardModel?> getProfileById(String id) async {
    final db = await instance.database;
    final result = await db.query('profiles', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return BusinessCardModel.fromMap(result.first);
    }
    return null;
  }

  Future<int> insertProfile(BusinessCardModel card) async {
    final db = await instance.database;
    if (card.isDefault) {
      // Bỏ default của các card khác
      await db.update('profiles', {'isDefault': 0});
    }
    return await db.insert('profiles', card.toMap());
  }

  Future<int> updateProfile(BusinessCardModel card) async {
    final db = await instance.database;
    if (card.isDefault) {
      await db.update('profiles', {'isDefault': 0});
    }
    final count = await db.update('profiles', card.toMap(), where: 'id = ?', whereArgs: [card.id]); if (count == 0) { await db.insert('profiles', card.toMap()); return 1; } return count;
  }

  Future<int> deleteProfile(String id) async {
    final db = await instance.database;
    await db.delete('analytics', where: 'cardId = ?', whereArgs: [id]);
    return await db.delete('profiles', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setDefaultProfile(String id) async {
    final db = await instance.database;
    await db.update('profiles', {'isDefault': 0});
    await db.update('profiles', {'isDefault': 1}, where: 'id = ?', whereArgs: [id]);
  }

  // ================= SAVED CONTACTS CRUD (CONTACT WALLET) ================= //
  Future<List<SavedContactModel>> getAllSavedContacts() async {
    final db = await instance.database;
    final result = await db.query('saved_contacts', orderBy: 'isFavorite DESC, metAt DESC');
    return result.map((map) => SavedContactModel.fromMap(map)).toList();
  }

  Future<int> insertSavedContact(SavedContactModel contact) async {
    final db = await instance.database;
    return await db.insert(
      'saved_contacts',
      contact.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateSavedContact(SavedContactModel contact) async {
    final db = await instance.database;
    return await db.update(
      'saved_contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<int> deleteSavedContact(String id) async {
    final db = await instance.database;
    return await db.delete('saved_contacts', where: 'id = ?', whereArgs: [id]);
  }

  // ================= ANALYTICS ================= //
  Future<CardAnalyticsModel> getAnalytics(String cardId) async {
    final db = await instance.database;
    final result = await db.query('analytics', where: 'cardId = ?', whereArgs: [cardId]);
    if (result.isNotEmpty) {
      return CardAnalyticsModel.fromMap(result.first);
    } else {
      final newAnalytics = CardAnalyticsModel(cardId: cardId);
      await db.insert('analytics', newAnalytics.toMap());
      return newAnalytics;
    }
  }

  Future<void> recordCardInteraction({
    required String cardId,
    bool isView = false,
    bool isSave = false,
    bool isQr = false,
    bool isNfc = false,
    String? clickedPlatform,
  }) async {
    final current = await getAnalytics(cardId);
    
    int newViews = current.totalViews + (isView ? 1 : 0);
    int newSaves = current.totalSaves + (isSave ? 1 : 0);
    int newQr = current.qrScans + (isQr ? 1 : 0);
    int newNfc = current.nfcTaps + (isNfc ? 1 : 0);

    Map<String, int> updatedClicks = Map.from(current.clickThroughRates);
    if (clickedPlatform != null) {
      updatedClicks[clickedPlatform] = (updatedClicks[clickedPlatform] ?? 0) + 1;
    }

    final updated = current.copyWith(
      totalViews: newViews,
      totalSaves: newSaves,
      qrScans: newQr,
      nfcTaps: newNfc,
      clickThroughRates: updatedClicks,
    );

    final db = await instance.database;
    await db.update(
      'analytics',
      updated.toMap(),
      where: 'cardId = ?',
      whereArgs: [cardId],
    );
  }
}
