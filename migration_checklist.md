# Habitdot 프로젝트 맥북 이전 체크리스트 (Migration Checklist)

이 파일은 다른 맥북으로 프로젝트를 안전하게 이전하기 위한 체크리스트입니다. 아래 단계에 따라 작업을 진행해 주세요.

---

## 1. 깃(Git) 푸시 (로컬 작업 내용 저장)

현재 프로젝트 폴더에 커밋되지 않은 코드 변경사항이 있습니다. 다음 명령어를 통해 모두 원격 저장소에 푸시합니다.

### 📌 실행할 Git 명령어
터미널에서 프로젝트 경로(`/Users/sikgates/Desktop/Habitdot`)로 이동한 뒤 아래 명령어를 순서대로 실행하세요.

```bash
# 1. 변경된 모든 파일 및 새로 생성된 파일 추가
git add .

# 2. 커밋 메시지와 함께 커밋 생성
git commit -m "chore: 맥북 이전을 위한 작업 내용 백업"

# 3. 원격 저장소의 main 브랜치로 푸시
git push origin main
```

### 📄 이번 푸시에 포함될 파일 목록
*   **새로 추가되는 파일 (Untracked)**:
    *   `Habitdot/Features/Onboarding/OnboardingFirstHabitView.swift`
    *   `Habitdot/Services/HabitdotPaywallEventService.swift`
*   **주요 수정된 파일**:
    *   Xcode 프로젝트 파일 (`Habitdot.xcodeproj/project.pbxproj`)
    *   탭 바 및 저장소 관련 로직 (`BottomTabBarView.swift`, `HabitStore.swift` 등)
    *   온보딩, 그리드, 페이월 관련 UI 파일들
    *   다국어 번역 리소스 (`Localizable.strings`)

---

## 2. 에어드랍(AirDrop)으로 전송할 폴더 목록

아래 폴더들은 `.gitignore` 파일에 등록되어 있어 Git 저장소에 올라가지 않습니다. **반드시 에어드랍(또는 외장하드)을 통해 따로 옮겨야 합니다.**

| 폴더명 | 설명 | 대략적인 크기 |
| :--- | :--- | :--- |
| `app-icon/` | 앱 아이콘 원본 리소스 (iOS, Android, Web) | ~2.1 MB |
| `concept/` | 앱 디자인 컨셉 이미지 파일들 | ~7.7 MB |
| `main/` | 메인 화면 관련 참고 리소스 | ~3.4 MB |
| `onboarding/` | 온보딩 디자인 이미지 파일들 | ~5.7 MB |
| `screenshots/` | App Store 등록용 다국어 스크린샷 폴더 | **~99 MB** (가장 큼) |
| `widgets/` | 위젯 화면 디자인 이미지 파일들 | ~15 MB |

> **⚠️ 주의:** `build/` 폴더는 용량이 크고(약 54MB) 새 맥북에서 Xcode 빌드 시 자동으로 다시 생성되므로 **에어드랍으로 보낼 필요가 없습니다.**

---

## 3. 새 맥북에서 복원하는 순서

1.  **새 맥북**에서 터미널을 열고 Git 원격 저장소에서 프로젝트를 클론합니다.
    ```bash
    git clone <저장소 주소> Habitdot
    ```
2.  **이전 맥북**에서 위의 **에어드랍 전송 대상 폴더 6개**(`app-icon`, `concept`, `main`, `onboarding`, `screenshots`, `widgets`)를 선택하여 새 맥북으로 보냅니다.
3.  새 맥북에서 에어드랍으로 받은 6개 폴더를 클론된 `Habitdot` 프로젝트의 **최상위 폴더(루트 경로) 밑에 그대로 복사해 넣습니다.**
4.  새 맥북의 Xcode에서 `Habitdot.xcodeproj` 프로젝트를 열어 정상적으로 빌드가 되는지 확인합니다.
