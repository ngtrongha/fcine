import 'package:flutter_test/flutter_test.dart';
import 'package:fcine/ui/features/player/logic/player_logic.dart';

void main() {
  group('shouldRecoverStream (phát hiện stream reset về đầu do ads)', () {
    test('đang phát tiến tới -> không phục hồi', () {
      expect(
        shouldRecoverStream(
          stableMs: 1200000,
          posMs: 1200500,
          seekLocked: false,
          recoverCount: 0,
        ),
        isFalse,
      );
    });

    test('tụt sâu >15s ngoài lúc seek -> phục hồi', () {
      expect(
        shouldRecoverStream(
          stableMs: 1200000,
          posMs: 5000,
          seekLocked: false,
          recoverCount: 0,
        ),
        isTrue,
      );
    });

    test('tụt ít hơn ngưỡng (nhiễu buffer/discontinuity) -> bỏ qua', () {
      expect(
        shouldRecoverStream(
          stableMs: 1200000,
          posMs: 1190000,
          seekLocked: false,
          recoverCount: 0,
        ),
        isFalse,
      );
      // đúng bằng ngưỡng thì phục hồi
      expect(
        shouldRecoverStream(
          stableMs: 1200000,
          posMs: 1185000,
          seekLocked: false,
          recoverCount: 0,
        ),
        isTrue,
      );
    });

    test('đang seek/open chủ động -> không phải reset', () {
      expect(
        shouldRecoverStream(
          stableMs: 1200000,
          posMs: 0,
          seekLocked: true,
          recoverCount: 0,
        ),
        isFalse,
      );
    });

    test('quá 3 lần phục hồi -> thôi, tránh lặp vô hạn', () {
      expect(
        shouldRecoverStream(
          stableMs: 1200000,
          posMs: 0,
          seekLocked: false,
          recoverCount: 3,
        ),
        isFalse,
      );
      expect(
        shouldRecoverStream(
          stableMs: 1200000,
          posMs: 0,
          seekLocked: false,
          recoverCount: 2,
        ),
        isTrue,
      );
    });
  });

  group('shouldSkipSaveOnRegress (giữ mốc resume khi stream reset)', () {
    test('vị trí tụt sâu so với mốc ổn định -> bỏ qua lượt lưu', () {
      expect(
        shouldSkipSaveOnRegress(stableMs: 1200000, posMs: 8000),
        isTrue,
      );
    });

    test('phát bình thường -> vẫn lưu', () {
      expect(
        shouldSkipSaveOnRegress(stableMs: 1200000, posMs: 1200500),
        isFalse,
      );
      expect(
        shouldSkipSaveOnRegress(stableMs: 1200000, posMs: 1190000),
        isFalse,
      );
    });
  });

  group('isGenuineCompletion (chống completed giả khi stream reset)', () {
    test('chưa biết duration -> không phải hết tập', () {
      expect(isGenuineCompletion(posMs: 0, durMs: 0), isFalse);
    });

    test('vị trí ở gần cuối phim -> hết tập thật', () {
      expect(
        isGenuineCompletion(posMs: 5390000, durMs: 5400000),
        isTrue,
      );
    });

    test('duration playlist bị phồng (kém tới 60s) -> vẫn hết tập', () {
      expect(
        isGenuineCompletion(posMs: 5340000, durMs: 5400000),
        isTrue,
      );
      expect(
        isGenuineCompletion(posMs: 5339000, durMs: 5400000),
        isFalse,
      );
    });

    test('vị trí còn xa cuối phim (reset giữa chừng) -> bỏ qua', () {
      expect(
        isGenuineCompletion(posMs: 30000, durMs: 5400000),
        isFalse,
      );
      expect(isGenuineCompletion(posMs: 0, durMs: 5400000), isFalse);
    });

    test('clip ngắn hơn ngưỡng đuôi -> luôn coi là hết tập', () {
      expect(isGenuineCompletion(posMs: 5000, durMs: 10000), isTrue);
    });
  });

  group('shouldAutoSkipStall (tự bỏ qua đoạn đứng hình nghi là ads)', () {
    test('đứng quá 10s giữa phim -> tự skip', () {
      expect(
        shouldAutoSkipStall(
          frozenSec: 10,
          posMs: 1200000,
          durMs: 5400000,
          autoSkipCount: 0,
        ),
        isTrue,
      );
    });

    test('mới đứng vài giây -> chờ thêm (mặc định chờ 5s)', () {
      expect(
        shouldAutoSkipStall(
          frozenSec: 3,
          posMs: 1200000,
          durMs: 5400000,
          autoSkipCount: 0,
        ),
        isFalse,
      );
      expect(
        shouldAutoSkipStall(
          frozenSec: 5,
          posMs: 1200000,
          durMs: 5400000,
          autoSkipCount: 0,
        ),
        isTrue,
      );
    });

    test('đứng ngay đầu phim (đang load) -> không skip', () {
      expect(
        shouldAutoSkipStall(
          frozenSec: 30,
          posMs: 2000,
          durMs: 5400000,
          autoSkipCount: 0,
        ),
        isFalse,
      );
    });

    test('đứng sát cuối phim -> không skip (kẻo tua mất đoạn kết)', () {
      expect(
        shouldAutoSkipStall(
          frozenSec: 30,
          posMs: 5390000,
          durMs: 5400000,
          autoSkipCount: 0,
        ),
        isFalse,
      );
    });

    test('vượt 4 lần/phim -> dừng (nghi mạng yếu, không tua mất nội dung)', () {
      expect(
        shouldAutoSkipStall(
          frozenSec: 30,
          posMs: 1200000,
          durMs: 5400000,
          autoSkipCount: 4,
        ),
        isFalse,
      );
      expect(
        shouldAutoSkipStall(
          frozenSec: 30,
          posMs: 1200000,
          durMs: 5400000,
          autoSkipCount: 3,
        ),
        isTrue,
      );
    });
  });

  group('StallWatcher (không báo oan khi phát bình thường)', () {
    test('ngưỡng mặc định 5s, chỉnh được theo Settings', () {
      final w = StallWatcher();
      expect(StallWatcher.kTriggerSec, 5);
      expect(w.triggerSec, 5);
      w.triggerSec = 8;
      expect(w.triggerSec, 8);
    });
    test('phát bình thường tiến ~1s/tick -> không bao giờ nghi', () {
      // Regression test cho bug "cứ 10s tự skip 30s dù không có ads":
      // logic cũ đòi tiến >1.5s mỗi tick 1s nên phát bình thường cũng
      // bị kết luận đứng hình.
      final w = StallWatcher();
      var t = DateTime(2026, 1, 1);
      var ms = 60000;
      for (int i = 0; i < 30; i++) {
        t = t.add(const Duration(seconds: 1));
        ms += 950 + (i % 3) * 50; // 950..1050ms mỗi tick như phát thật
        expect(w.tick(ms, t), 0, reason: 'tick $i báo oan đứng hình');
      }
    });

    test('đứng yên thật -> đếm giây, đủ ngưỡng thì báo', () {
      final w = StallWatcher();
      var t = DateTime(2026, 1, 1);
      expect(w.tick(60000, t), 0);
      // Tick đứng đầu tiên chỉ "bắt đầu nghi" (trả 0), các tick sau đếm lên.
      for (int i = 1; i <= StallWatcher.kTriggerSec + 1; i++) {
        t = t.add(const Duration(seconds: 1));
        expect(w.tick(60000, t), i - 1);
      }
      // Qua ngưỡng mà vẫn đứng -> tiếp tục đếm để caller skip.
      t = t.add(const Duration(seconds: 1));
      expect(w.tick(60000, t), StallWatcher.kTriggerSec + 1);
    });

    test('đứng vài giây rồi phát tiếp -> hết nghi', () {
      final w = StallWatcher();
      var t = DateTime(2026, 1, 1);
      w.tick(60000, t);
      for (int i = 0; i < 5; i++) {
        t = t.add(const Duration(seconds: 1));
        w.tick(60000, t);
      }
      t = t.add(const Duration(seconds: 1));
      expect(w.tick(65000, t), 0); // tiến 5s so baseline -> hết nghi
      t = t.add(const Duration(seconds: 1));
      expect(w.tick(66000, t), 0); // phát bình thường tiếp
    });

    test('reset() xóa trạng thái nghi', () {
      final w = StallWatcher();
      var t = DateTime(2026, 1, 1);
      w.tick(60000, t);
      t = t.add(const Duration(seconds: 1));
      expect(w.tick(60000, t), 0); // bắt đầu nghi
      w.reset();
      t = t.add(const Duration(seconds: 1));
      // sau reset, đứng tiếp thì tính lại từ đầu chứ không cộng dồn
      expect(w.tick(60000, t), 0);
      t = t.add(const Duration(seconds: 1));
      expect(w.tick(60000, t), 1);
    });
  });

  group('introTickAction (chống skip intro oan khi gặp ads)', () {
    test('chưa đặt mốc hoặc đã skip -> none', () {
      expect(
        introTickAction(introEndMs: 0, hasSkipped: false, posMs: 30000),
        IntroTick.none,
      );
      expect(
        introTickAction(introEndMs: 90000, hasSkipped: true, posMs: 30000),
        IntroTick.none,
      );
    });

    test('xem từ đầu, vào vùng intro -> skip 1 lần', () {
      expect(
        introTickAction(introEndMs: 90000, hasSkipped: false, posMs: 5000),
        IntroTick.skip,
      );
    });

    test('resume giữa phim (chưa từng skip) -> latch, không skip', () {
      // ĐÚNG kịch bản lỗi: mở lại phim ở phút 20, cờ vẫn false; gặp ads
      // làm vị trí tụt về vùng intro cũng không được skip oan về mốc.
      expect(
        introTickAction(
          introEndMs: 90000,
          hasSkipped: false,
          posMs: 1200000,
        ),
        IntroTick.latch,
      );
      // Sau latch, tụt vị trí vào vùng intro -> none (cờ đã chốt).
      expect(
        introTickAction(introEndMs: 90000, hasSkipped: true, posMs: 30000),
        IntroTick.none,
      );
    });

    test('đầu phim (<1s) và vùng chết trước mốc -> none', () {
      expect(
        introTickAction(introEndMs: 90000, hasSkipped: false, posMs: 500),
        IntroTick.none,
      );
      expect(
        introTickAction(introEndMs: 90000, hasSkipped: false, posMs: 89700),
        IntroTick.none,
      );
    });
  });

  group('shouldShowSkipOutro (nút Bỏ qua outro)', () {
    test('vào vùng outro và chưa xử lý -> hiện nút', () {
      expect(
        shouldShowSkipOutro(
          outroStartMs: 5000000,
          handled: false,
          posMs: 5001000,
        ),
        isTrue,
      );
    });

    test('chưa đặt mốc / đã xử lý / chưa tới vùng -> ẩn', () {
      expect(
        shouldShowSkipOutro(
          outroStartMs: 0,
          handled: false,
          posMs: 5001000,
        ),
        isFalse,
      );
      expect(
        shouldShowSkipOutro(
          outroStartMs: 5000000,
          handled: true,
          posMs: 5001000,
        ),
        isFalse,
      );
      expect(
        shouldShowSkipOutro(
          outroStartMs: 5000000,
          handled: false,
          posMs: 1000000,
        ),
        isFalse,
      );
    });
  });

  group('isSkipIneffective (skip không ăn thua -> nghi mạng yếu)', () {
    test('đứng tiếp loanh quanh điểm đáp -> không hiệu quả', () {
      expect(
        isSkipIneffective(posMs: 1230000, landedMs: 1230000),
        isTrue,
      );
      expect(
        isSkipIneffective(posMs: 1238000, landedMs: 1230000),
        isTrue,
      );
    });

    test('đã phát đi xa (hoặc user tua đi chỗ khác) -> hiệu quả', () {
      expect(
        isSkipIneffective(posMs: 1500000, landedMs: 1230000),
        isFalse,
      );
      expect(
        isSkipIneffective(posMs: 600000, landedMs: 1230000),
        isFalse,
      );
    });
  });
}
