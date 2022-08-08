### 솔리디티 사용 가이드
```
Extention에서 solidity 설치
f1 키에 solidity compile version과 solidity compile 가능

```
#### NFT
```
NFT Contract를 발행하면 발행된 주소가 관리자가되어 해당Contract에 관한 token의 mint(생성)가 가능하다
mint 된 token은 고유한 ID를 가지며 대체 불가능하다
mint되어 고유한 Token을 가지고있는 주소는 Contract 내용이 해당주소에 없을경우 token에 대한 관리자 기능을 하지못하여 Transfer , approve 기능을 사용할수없다
mint 되어 받은 Token의 전송(transfer)를 사용하고싶다면 같은 내용의 Contract를 발행해줘야한다
Contract 내용을 가지고있는 주소는 관리자가 되어 mint, transfer, approve 함수등등 사용할수있다
approve 함수는 Contract에 대한 내용을 가지고있는 주소가 Token에 대한 Contract 기능을 가지지 않더라도 Transfer할수있도록 권한을 부여하는 함수이다
Token의 owner는 관리자이겠지만 권한을 부여받은 주소는 해당토큰에대해 Transfer를 사용할수있다
approve 기능을 부여받은 주소가 trasfer후 해당토큰은 받은주소가 Contract기능을 가지고있지 않다면 다시 approve 기능을 사용할수없다.