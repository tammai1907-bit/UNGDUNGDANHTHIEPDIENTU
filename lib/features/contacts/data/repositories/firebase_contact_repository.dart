import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/saved_contact.dart';
import '../../domain/repositories/contact_repository.dart';

class FirebaseContactRepository implements ContactRepository {
  final FirebaseFirestore _firestore;

  FirebaseContactRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _contactsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('contacts');
  }

  @override
  Stream<List<SavedContact>> watchContacts(String userId) {
    return _contactsRef(userId)
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return SavedContact.fromMap(data);
      }).toList();
    });
  }

  @override
  Future<List<SavedContact>> getContacts(String userId) async {
    final snapshot = await _contactsRef(userId).orderBy('savedAt', descending: true).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return SavedContact.fromMap(data);
    }).toList();
  }

  @override
  Future<SavedContact?> getContactById(String userId, String contactId) async {
    final doc = await _contactsRef(userId).doc(contactId).get();
    if (!doc.exists || doc.data() == null) return null;
    final data = doc.data()!;
    data['id'] = doc.id;
    return SavedContact.fromMap(data);
  }

  @override
  Future<void> saveContact(String userId, SavedContact contact) async {
    await _contactsRef(userId).doc(contact.id).set(contact.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> updateContact(String userId, SavedContact contact) async {
    await _contactsRef(userId).doc(contact.id).update(contact.toMap());
  }

  @override
  Future<void> deleteContact(String userId, String contactId) async {
    await _contactsRef(userId).doc(contactId).delete();
  }

  @override
  Future<List<String>> getAvailableTags(String userId) async {
    final contacts = await getContacts(userId);
    final tagSet = <String>{'Tất cả', 'Khách hàng', 'Đối tác', 'Đồng nghiệp', 'Bạn bè', 'VIP', 'Hội thảo'};
    for (final c in contacts) {
      tagSet.addAll(c.tags);
    }
    return tagSet.toList();
  }
}
