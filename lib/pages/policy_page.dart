import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

enum PolicyType { appLogin, consult }

class PolicyPage extends StatelessWidget {
  const PolicyPage({
    super.key,
    required this.onAccept,
    this.type = PolicyType.appLogin,
    this.confirmText,
  });

  final VoidCallback onAccept;
  final PolicyType type;
  final String? confirmText;

  _PolicyContent get _content {
    switch (type) {
      case PolicyType.consult:
        return const _PolicyContent(
          title: 'ข้อตกลงก่อนปรึกษาสัตวแพทย์',
          intro:
              'บริการปรึกษาสัตวแพทย์นี้จัดทำขึ้นเพื่อช่วยให้ผู้ใช้งานขอคำแนะนำเบื้องต้นเกี่ยวกับสุขภาพสัตว์เลี้ยงได้สะดวกขึ้น ก่อนเริ่มใช้งาน กรุณาอ่านข้อตกลงฉบับนี้อย่างละเอียด',
          confirmText: 'ยอมรับและเริ่มปรึกษา',
          sections: [
            _PolicySection(
              title: '1. การใช้บริการ',
              body:
                  'บริการนี้เป็นการปรึกษาเบื้องต้น ไม่ใช่การวินิจฉัยหรือการรักษาแทนสัตวแพทย์ที่ตรวจร่างกายจริง หากสัตว์มีอาการรุนแรงหรือฉุกเฉิน เช่น หายใจลำบาก ชัก หมดสติ เลือดออกมาก หรือถูกทำร้าย ควรพาไปพบสัตวแพทย์ทันที',
            ),
            _PolicySection(
              title: '2. ข้อมูลที่ควรส่ง',
              body:
                  'ผู้ใช้งานควรส่งข้อมูลที่ถูกต้องและครบถ้วน เช่น ชื่อสัตว์ อาการ ระยะเวลาที่เริ่มเป็น รูปภาพ วิดีโอ หรือประวัติการรักษาที่เกี่ยวข้อง เพื่อให้การตอบกลับใกล้เคียงสถานการณ์จริงมากที่สุด',
            ),
            _PolicySection(
              title: '3. การเก็บข้อมูลการปรึกษา',
              body:
                  'ข้อความ รูปภาพ วิดีโอ และข้อมูลที่เกี่ยวข้องกับการปรึกษา อาจถูกบันทึกเป็นประวัติการให้บริการ เพื่อใช้ติดตามผลการรักษาและอำนวยความสะดวกในการให้คำแนะนำครั้งถัดไป',
            ),
            _PolicySection(
              title: '4. ความเป็นส่วนตัว',
              body:
                  'ข้อมูลของผู้ใช้งานและสัตว์เลี้ยงจะถูกใช้เฉพาะเพื่อการให้บริการในระบบเท่านั้น และจะไม่ถูกเปิดเผยต่อบุคคลอื่นโดยไม่จำเป็น เว้นแต่เป็นไปตามข้อกำหนดของหน่วยงานหรือกฎหมายที่เกี่ยวข้อง',
            ),
            _PolicySection(
              title: '5. ข้อจำกัดของบริการ',
              body:
                  'ระบบอาจมีเวลารอการตอบกลับ และคำแนะนำขึ้นอยู่กับข้อมูลที่ผู้ใช้งานส่งเข้ามา หากข้อมูลไม่ครบถ้วนหรือไม่ชัดเจน เจ้าหน้าที่อาจขอรายละเอียดเพิ่มเติมก่อนให้คำแนะนำต่อ',
            ),
          ],
        );
      case PolicyType.appLogin:
        return const _PolicyContent(
          title: 'นโยบายการใช้งานแอปพลิเคชัน BKK Pet',
          intro:
              'แอปพลิเคชันนี้จัดทำขึ้นเพื่อให้บริการข้อมูลและบริการด้านสัตว์เลี้ยงแก่ประชาชน ผู้ใช้งานโปรดอ่านและทำความเข้าใจนโยบายฉบับนี้ก่อนกดยอมรับ',
          confirmText: 'ยอมรับและเข้าสู่ระบบ',
          sections: [
            _PolicySection(
              title: '1. การยอมรับเงื่อนไขการใช้งาน',
              body:
                  'เมื่อผู้ใช้งานกด “ยอมรับ” ถือว่าผู้ใช้งานรับทราบและยินยอมปฏิบัติตามนโยบายการใช้งาน ข้อกำหนด และเงื่อนไขต่าง ๆ ของแอปพลิเคชันนี้ทุกประการ',
            ),
            _PolicySection(
              title: '2. การใช้งานบัญชีและการยืนยันตัวตน',
              body:
                  'ผู้ใช้งานต้องให้ข้อมูลที่ถูกต้อง ครบถ้วน และเป็นปัจจุบันในการสมัครใช้งานหรือยืนยันตัวตนผ่านแอปพลิเคชัน หากมีการเข้าถึงข้อมูลสำคัญ ระบบอาจกำหนดให้ยืนยันตัวตนเพิ่มเติมตามความเหมาะสม',
            ),
            _PolicySection(
              title: '3. การเก็บ ใช้ และประมวลผลข้อมูลส่วนบุคคล',
              body:
                  'แอปพลิเคชันมีการเก็บ ใช้ และประมวลผลข้อมูลส่วนบุคคลของผู้ใช้งานเท่าที่จำเป็น เพื่อใช้สำหรับการสมัครสมาชิก การเข้าสู่ระบบ การยืนยันตัวตน และการให้บริการภายในแอปพลิเคชัน',
            ),
            _PolicySection(
              title: '4. การให้บริการและการแจ้งเตือน',
              body:
                  'ระบบอาจนำข้อมูลที่เกี่ยวข้องมาใช้เพื่อแนะนำบริการ ข่าวสาร หรือสิทธิประโยชน์ที่เหมาะสม รวมถึงการส่งการแจ้งเตือนที่เกี่ยวข้องกับการใช้งานและการติดตามผล',
            ),
            _PolicySection(
              title: '5. ข้อห้ามและความถูกต้องของข้อมูล',
              body:
                  'ผู้ใช้งานต้องไม่ใช้ข้อมูลเท็จ แอบอ้าง แก้ไข ปลอมแปลง หรือใช้งานแอปพลิเคชันในทางที่ผิดกฎหมาย และควรตรวจสอบข้อมูลกับหน่วยงานที่เกี่ยวข้องอีกครั้งหากต้องใช้เป็นทางการ',
            ),
            _PolicySection(
              title: '6. การเปลี่ยนแปลงนโยบายและการติดต่อสอบถาม',
              body:
                  'หน่วยงานขอสงวนสิทธิ์ในการปรับปรุงนโยบายนี้ตามความเหมาะสม และผู้ใช้งานสามารถติดต่อสอบถามเกี่ยวกับการใช้งานหรือข้อมูลส่วนบุคคลผ่านช่องทางที่กำหนดภายในแอปพลิเคชัน',
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _content;
    return Scaffold(
      backgroundColor: AppColors.greyscale_25,
      appBar: AppBarMainApp(
        title: content.title,
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.greyscale_200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.greyscale_900,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content.intro,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: AppColors.greyscale_400,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ...content.sections.map(
                    (section) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              section.title,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.greyscale_900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              section.body,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.65,
                                fontWeight: FontWeight.w600,
                                color: AppColors.greyscale_800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  onAccept();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  confirmText ?? content.confirmText,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.greyscale_300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'ยังไม่ยอมรับ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.greyscale_800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicyContent {
  const _PolicyContent({
    required this.title,
    required this.intro,
    required this.confirmText,
    required this.sections,
  });

  final String title;
  final String intro;
  final String confirmText;
  final List<_PolicySection> sections;
}

class _PolicySection {
  const _PolicySection({required this.title, required this.body});

  final String title;
  final String body;
}
