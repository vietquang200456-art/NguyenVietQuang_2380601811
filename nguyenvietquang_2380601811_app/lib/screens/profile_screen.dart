import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';

class ProfileScreen extends StatefulWidget {
  final AuthController authController;
  const ProfileScreen({super.key, required this.authController});
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _fullNameController, _emailController, _phoneController;
  @override void initState() { super.initState(); final u=widget.authController.currentUser!; _fullNameController=TextEditingController(text:u.fullName); _emailController=TextEditingController(text:u.email); _phoneController=TextEditingController(text:u.phoneNumber??''); }
  @override void dispose() { _fullNameController.dispose(); _emailController.dispose(); _phoneController.dispose(); super.dispose(); }
  Future<void> _save() async { if(_fullNameController.text.trim().isEmpty||_emailController.text.trim().isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Họ tên và email không được để trống.')));return;} final ok=await widget.authController.updateProfile(fullName:_fullNameController.text,email:_emailController.text,phoneNumber:_phoneController.text); if(!mounted)return; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(ok?'Đã lưu toàn bộ thay đổi hồ sơ.':(widget.authController.errorMessage??'Không thể lưu hồ sơ.')))); if(ok)setState((){}); }
  @override Widget build(BuildContext context) { final u=widget.authController.currentUser; if(u==null)return const Scaffold(body:Center(child:Text('Chưa đăng nhập.'))); return Scaffold(appBar:AppBar(title:const Text('Hồ sơ cá nhân')),body:ListView(padding:const EdgeInsets.all(20),children:[Center(child:CircleAvatar(radius:42,child:Text((u.fullName.isEmpty?'U':u.fullName[0]).toUpperCase(),style:const TextStyle(fontSize:32)))),const SizedBox(height:24),_field('Tên đăng nhập',u.username,Icons.account_circle_outlined),_field('Họ và tên',_fullNameController.text,Icons.badge_outlined,controller:_fullNameController),_field('Email',_emailController.text,Icons.email_outlined,controller:_emailController,keyboardType:TextInputType.emailAddress),_field('Số điện thoại',_phoneController.text,Icons.phone_outlined,controller:_phoneController,keyboardType:TextInputType.phone),_field('Vai trò',u.role,Icons.security_outlined),_field('Ngày tạo tài khoản',u.createdAt?.toLocal().toString().split(' ').first??'Chưa cập nhật',Icons.calendar_today_outlined),const SizedBox(height:12),FilledButton.icon(onPressed:widget.authController.isLoading?null:_save,icon:const Icon(Icons.save_outlined),label:Text(widget.authController.isLoading?'Đang lưu...':'Lưu toàn bộ thay đổi'))])); }
  Widget _field(String label,String value,IconData icon,{TextEditingController? controller,TextInputType? keyboardType})=>Padding(padding:const EdgeInsets.only(bottom:14),child:TextField(controller:controller??TextEditingController(text:value),readOnly:controller==null,keyboardType:keyboardType,decoration:InputDecoration(labelText:label,prefixIcon:Icon(icon),border:const OutlineInputBorder())));
}
