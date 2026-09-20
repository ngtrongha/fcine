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

    test('mới đứng vài giây -> chờ thêm', () {
      expect(
        shouldAutoSkipStall(
          frozenSec: 5,
          posMs: 1200000,
          durMs: 5400000,
          autoSkipCount: 0,
        ),
        isFalse,
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
