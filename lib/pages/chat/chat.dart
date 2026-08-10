import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/pages/chat/message_chat.dart';
import 'package:bkkpet/pages/consult/consult_page_models.dart';
import 'package:bkkpet/style_theme.dart';

import 'package:flutter/material.dart';

class chatPage extends StatefulWidget {
  const chatPage({super.key, required this.onTabChange});
  final void Function(int index) onTabChange;

  @override
  State<chatPage> createState() => _chatPageState();
}

class _chatPageState extends State<chatPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<_DoctorChatItem> _chatList = [
    _DoctorChatItem(
      doctor: consultDoctors[0],
      lastMessage: 'มีเอกสารที่เกี่ยวข้องมั้ยครับ',
      time: '14:28',
      unread: 1,
      initialMessages: [
        ChatMessage(text: 'สวัสดีครับ วันนี้มีอะไรให้ช่วยไหมครับ', isMe: false),
        ChatMessage(text: 'มีเอกสารที่เกี่ยวข้องมั้ยครับ', isMe: false),
      ],
    ),
    _DoctorChatItem(
      doctor: consultDoctors[1],
      lastMessage: 'ได้รับแล้วครับ',
      time: 'เมื่อวาน',
      unread: 2,
      initialMessages: [
        ChatMessage(text: 'ส่งผลตรวจให้แล้วนะคะ', isMe: false),
        ChatMessage(text: 'ได้รับแล้วครับ', isMe: true),
      ],
    ),
    _DoctorChatItem(
      doctor: consultDoctors[2],
      lastMessage: 'ขอบคุณครับ',
      time: 'เมื่อวาน',
      unread: 0,
      initialMessages: [
        ChatMessage(text: 'นัดหมายเรียบร้อยแล้วครับ', isMe: true),
        ChatMessage(text: 'ขอบคุณครับ', isMe: false),
      ],
    ),
    _DoctorChatItem(
      doctor: consultDoctors[3],
      lastMessage: 'เดี๋ยวช่วยดูเคสให้นะคะ',
      time: '09:12',
      unread: 0,
      initialMessages: [
        ChatMessage(text: 'มีพฤติกรรมที่อยากปรึกษาไหมคะ', isMe: false),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openChat(_DoctorChatItem chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => MessageChatPage(
              doctorName: chat.doctor.name,
              profileImage: chat.doctor.imageUrl,
              isOnline: chat.doctor.isOnlineNow,
              initialMessages: chat.initialMessages,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(title: 'แชท', onBack: () => widget.onTabChange(0)),
      body: SafeArea(
        top: false,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: _chatList.length,
          separatorBuilder:
              (_, __) =>
                  Divider(height: 1, color: Colors.grey.withOpacity(0.15)),
          itemBuilder: (context, index) {
            final chat = _chatList[index];
            return _ChatListTile(
              name: chat.doctor.name,
              image: chat.doctor.imageUrl,
              specialty: chat.doctor.specialty,
              lastMessage: chat.lastMessage,
              time: chat.time,
              unread: chat.unread,
              isOnline: chat.doctor.isOnlineNow,
              onTap: () => _openChat(chat),
            );
          },
        ),
      ),
    );
  }
}

/// -------------------------
/// การ์ดรายการแชทแต่ละแถว
/// -------------------------
class _ChatListTile extends StatelessWidget {
  const _ChatListTile({
    required this.name,
    required this.image,
    required this.specialty,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.isOnline,
    required this.onTap,
  });

  final String name;
  final String image;
  final String specialty;
  final String lastMessage;
  final String time;
  final int unread;
  final bool isOnline;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasUnread = unread > 0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// รูปโปรไฟล์ + สถานะออนไลน์
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xffE7EFE9),
                  backgroundImage: AssetImage(image),
                ),
                if (isOnline)
                  Positioned(
                    right: 0,
                    top: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.greenlight,
                        shape: BoxShape.circle,
                        // border: Border.all(
                        //   color: const Color.fromARGB(255, 40, 32, 32),
                        //   width: 2,
                        // ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            /// ชื่อ + ข้อความล่าสุด
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    specialty,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lastMessage,
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          hasUnread
                              ? AppColors.greenlight
                              : Colors.grey.shade500,
                      fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            /// เวลา + ตัวเลขข้อความที่ยังไม่อ่าน
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 6),
                if (hasUnread)
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$unread',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorChatItem {
  const _DoctorChatItem({
    required this.doctor,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.initialMessages,
  });

  final ConsultDoctor doctor;
  final String lastMessage;
  final String time;
  final int unread;
  final List<ChatMessage> initialMessages;
}
