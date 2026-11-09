import '../entities/saved_contact.dart';

abstract class ContactRepository {
  Stream<List<SavedContact>> watchContacts(String userId);
  Future<List<SavedContact>> getContacts(String userId);
  Future<SavedContact?> getContactById(String userId, String contactId);
  Future<void> saveContact(String userId, SavedContact contact);
  Future<void> updateContact(String userId, SavedContact contact);
  Future<void> deleteContact(String userId, String contactId);
  Future<List<String>> getAvailableTags(String userId);
}
