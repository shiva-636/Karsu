import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../networking/api_client.dart';

class AppState extends ChangeNotifier {
  String? userId, name, email; bool loading=false, initialized=false, onboardingComplete=false; String? error;
  bool get signedIn => userId != null && apiClient.token != null;

  Future<void> initialize() async {
    final prefs=await SharedPreferences.getInstance();
    apiClient.token=prefs.getString('token'); userId=prefs.getString('userId'); name=prefs.getString('name'); email=prefs.getString('email');
    if(apiClient.token != null){
      try {
        final me=await apiClient.get('/users/me'); _setUser(Map<String,dynamic>.from(me));
        final businesses=await apiClient.get('/businesses'); onboardingComplete=(businesses['data'] is List ? (businesses['data'] as List) : const []).isNotEmpty;
      } catch (_) { await _clearSession(prefs); }
    }
    initialized=true; notifyListeners();
  }
  Future<bool> signIn(String emailValue,String password) async => _auth(() async { final result=await apiClient.post('/auth/login',{'email':emailValue,'password':password}); await _setSession(result); final businesses=await apiClient.get('/businesses'); onboardingComplete=(businesses['data'] is List ? (businesses['data'] as List) : const []).isNotEmpty; });
  Future<bool> register(String nameValue,String emailValue,String password) async => _auth(() async { final result=await apiClient.post('/auth/register',{'name':nameValue,'email':emailValue,'password':password,'preferredLanguage':'English'}); await _setSession(result); onboardingComplete=false; });
  void _setUser(Map<String,dynamic> user){ userId=user['id']?.toString(); name=user['name']?.toString(); email=user['email']?.toString(); }
  Future<void> _setSession(Map<String,dynamic> result) async { apiClient.token=result['token']?.toString(); _setUser(Map<String,dynamic>.from(result['user'] as Map)); final p=await SharedPreferences.getInstance(); await p.setString('token',apiClient.token!); await p.setString('userId',userId!); if(name!=null) await p.setString('name',name!); if(email!=null) await p.setString('email',email!); }
  Future<bool> _auth(Future<void> Function() action) async { loading=true; error=null; notifyListeners(); try{await action();return true;}catch(e){error=e.toString();return false;}finally{loading=false;notifyListeners();} }
  Future<void> _clearSession(SharedPreferences p) async { apiClient.token=null; userId=null; name=null; email=null; onboardingComplete=false; await p.remove('token'); await p.remove('userId'); await p.remove('name'); await p.remove('email'); }
  Future<void> signOut() async { try { if(apiClient.token != null) await apiClient.post('/auth/logout',{}); } catch (_) {} final p=await SharedPreferences.getInstance(); await _clearSession(p); error=null; notifyListeners(); }
}
final appState=AppState();
