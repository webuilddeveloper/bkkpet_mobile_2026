import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/blank_page/app_media_icon.dart';
import 'package:bkkpet/pages/chat/chat_thread_info_page.dart';
import 'package:bkkpet/pages/chat/message_call_connecting.dart';

import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// ประเภทของข้อความ
enum ChatMessageType { text, image }

/// โมเดลข้อความแชทอย่างง่าย
class ChatMessage {
  final String? text;
  final String? imagePath; // path ของไฟล์รูปในเครื่อง
  final ChatMessageType type;
  final bool isMe;
  final DateTime time;

  ChatMessage({
    this.text,
    this.imagePath,
    this.type = ChatMessageType.text,
    required this.isMe,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}

class MessageChatPage extends StatefulWidget {
  const MessageChatPage({
    super.key,
    this.doctorName = 'น.สพ. ดลชัย จงภักดี',
    this.profileImage = 'assets/images/doctor.png',
    this.isOnline = true,
    this.initialMessages,
  });

  /// ชื่อคู่สนทนา (หมอ/สัตวแพทย์)
  final String doctorName;

  /// รูปโปรไฟล์คู่สนทนา
  final String profileImage;

  /// สถานะออนไลน์
  final bool isOnline;

  /// ข้อความเริ่มต้นของแชท (ถ้ามี) เช่นตอนกดเข้าจากหน้า list แชท
  final List<ChatMessage>? initialMessages;

  @override
  State<MessageChatPage> createState() => _MessageChatPageState();
}

class _MessageChatPageState extends State<MessageChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final ImagePicker _picker = ImagePicker();

  /// สถานะกำลังพิมพ์ (จำลองหมอกำลังตอบ)
  bool _isTyping = false;

  /// ปิดเสียงแจ้งเตือนจากห้องแชทนี้
  bool _muted = false;

  /// ชุดข้อความตอบกลับอัตโนมัติ (จำลอง เพื่อ demo/UI เท่านั้น)
  final List<String> _autoReplies = [
    'สวัสดีครับ รอสักครู่นะครับ กำลังดูข้อมูลให้อยู่ครับ',
    'ได้รับข้อความแล้วครับ เดี๋ยวหมอจะรีบตอบกลับนะครับ',
    'ขอบคุณสำหรับข้อมูลครับ รบกวนรอสักครู่นะครับ',
    'รับทราบครับ ขอเช็คประวัติก่อนนะครับ',
  ];

  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    if (widget.initialMessages != null) {
      _messages.addAll(widget.initialMessages!);
    }

    if (_messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      if (animate) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isMe: true));
      _textController.clear();
    });

    _scrollToBottom();
    _simulateAutoReply();
  }

  void _sendImageMessage(String path) {
    setState(() {
      _messages.add(
        ChatMessage(imagePath: path, type: ChatMessageType.image, isMe: true),
      );
    });

    _scrollToBottom();
    _simulateAutoReply();
  }

  void _simulateAutoReply() {
    _typingTimer?.cancel();

    setState(() => _isTyping = true);
    _scrollToBottom();

    final delayMs = 1200 + Random().nextInt(1000);

    _typingTimer = Timer(Duration(milliseconds: delayMs), () {
      if (!mounted) return;

      final reply = _autoReplies[Random().nextInt(_autoReplies.length)];

      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(text: reply, isMe: false));
      });

      _scrollToBottom();
    });
  }

  /// เปิดตัวเลือก "ถ่ายรูป" หรือ "เลือกจากคลัง"
  Future<void> _showImageSourceSheet() async {
    // ปิดคีย์บอร์ดก่อนเปิด sheet
    FocusScope.of(context).unfocus();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const AppMediaIcon(
                  asset: appCameraIconAsset,
                  fallbackIcon: Icons.photo_camera_outlined,
                ),
                title: const Text('ถ่ายรูป'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const AppMediaIcon(
                  asset: appGalleryIconAsset,
                  fallbackIcon: Icons.photo_library_outlined,
                ),
                title: const Text('เลือกจากคลังภาพ'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1600,
      );

      if (picked != null) {
        _sendImageMessage(picked.path);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ไม่สามารถเข้าถึงรูปภาพได้: $e')));
    }
  }

  Future<void> _showMoreMenu() async {
    final sentImages =
        _messages
            .where(
              (message) =>
                  message.isMe &&
                  message.type == ChatMessageType.image &&
                  message.imagePath != null,
            )
            .map((message) => message.imagePath!)
            .toList();

    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.42),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slide = Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );
          return SlideTransition(position: slide, child: child);
        },
        pageBuilder: (_, __, ___) {
          return ChatThreadInfoPage(
            doctorName: widget.doctorName,
            profileImage: widget.profileImage,
            isOnline: widget.isOnline,
            isMuted: _muted,
            sentImages: sentImages,
            onMutedChanged: (value) {
              if (!mounted) return;
              setState(() => _muted = value);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffE7EFE9),
      appBar: AppBarChat(
        doctorName: widget.doctorName,
        profileImage: widget.profileImage,
        isOnline: widget.isOnline,
        onBack: () => Navigator.pop(context),
        onCallTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => MessageCallConnectingPage(
                    doctorName: widget.doctorName,
                    doctorImage: widget.profileImage,
                  ),
            ),
          );
        },
        onMoreTap: _showMoreMenu,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child:
                  (_messages.isEmpty && !_isTyping)
                      ? const SizedBox.shrink()
                      : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        itemCount: _messages.length + (_isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _messages.length && _isTyping) {
                            return const _TypingBubble();
                          }
                          final msg = _messages[index];
                          return _ChatBubble(message: msg);
                        },
                      ),
            ),
            _MessageInputBar(
              controller: _textController,
              onSend: _sendMessage,
              onPickImage: _showImageSourceSheet,
            ),
          ],
        ),
      ),
    );
  }
}

/// -------------------------
/// ฟองข้อความ (รองรับทั้งข้อความและรูปภาพ)
/// -------------------------
class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final isImage = message.type == ChatMessageType.image;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding:
            isImage
                ? const EdgeInsets.all(4)
                : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color:
              isImage
                  ? Colors.transparent
                  : (isMe ? AppColors.greenlight : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child:
            isImage
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: GestureDetector(
                    onTap: () => _openFullImage(context, message.imagePath!),
                    child: Image.file(
                      File(message.imagePath!),
                      fit: BoxFit.cover,
                      width: 200,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            width: 200,
                            height: 150,
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                    ),
                  ),
                )
                : Text(
                  message.text ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: isMe ? Colors.white : Colors.black87,
                  ),
                ),
      ),
    );
  }

  void _openFullImage(BuildContext context, String path) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) {
        return GestureDetector(
          onTap: () => Navigator.pop(ctx),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: InteractiveViewer(child: Image.file(File(path))),
            ),
          ),
        );
      },
    );
  }
}

/// -------------------------
/// ฟองข้อความ "กำลังพิมพ์..." (typing indicator)
/// -------------------------
class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final t = (_controller.value + (i * 0.2)) % 1.0;
                final dy = -4 * sin(t * pi);
                return Transform.translate(offset: Offset(0, dy), child: child);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xffB5C2BB),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// -------------------------
/// ช่องพิมพ์ข้อความ + ปุ่มรูปภาพ + ปุ่มส่ง
/// อิโมจิใช้คีย์บอร์ดของเครื่อง (ไม่มี picker แยกในแอปแล้ว)
/// -------------------------
class _MessageInputBar extends StatefulWidget {
  const _MessageInputBar({
    required this.controller,
    required this.onSend,
    required this.onPickImage,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onPickImage;

  @override
  State<_MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<_MessageInputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                // ไม่ต้องตั้งค่าอะไรเพิ่ม — ปุ่มอิโมจิของคีย์บอร์ด
                // เครื่อง (globe/emoji key บน iOS, Gboard บน Android)
                // ใช้งานได้จาก TextField ปกติอยู่แล้ว
                onSubmitted: (_) => widget.onSend(),
                decoration: const InputDecoration(
                  hintText: 'พิมพ์ข้อความ....',
                  hintStyle: TextStyle(
                    color: AppColors.greyscale_800,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
              ),
            ),
            const SizedBox(width: 8),

            /// ปุ่มรูปภาพ/สติกเกอร์ -> เปิดตัวเลือกถ่ายรูป/เลือกจากคลัง
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const AppMediaIcon(
                asset: appGalleryIconAsset,
                fallbackIcon: Icons.image_outlined,
                size: 22,
              ),
              onPressed: widget.onPickImage,
            ),
            const SizedBox(width: 8),

            /// ปุ่มส่งข้อความ
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _hasText ? widget.onSend : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _hasText ? AppColors.greenlight : const Color(0xffB5C2BB),
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
