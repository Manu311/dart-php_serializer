import 'package:php_serializer/php_serializer.dart';
import 'package:test/test.dart';

void main() {
  test('Actual example from Symfony', () {
    const serialized =
        'O:36:"Symfony\\Component\\Messenger\\Envelope":2:{s:44:"\0Symfony\\Component\\Messenger\\Envelope\0stamps";a:1:{s:46:"Symfony\\Component\\Messenger\\Stamp\\BusNameStamp";a:1:{i:0;O:46:"Symfony\\Component\\Messenger\\Stamp\\BusNameStamp":1:{s:55:"\0Symfony\\Component\\Messenger\\Stamp\\BusNameStamp\0busName";s:21:"messenger.bus.default";}}}s:45:"\0Symfony\\Component\\Messenger\\Envelope\0message";O:42:"App\\Queue\\UserAccount\\CreateUserAccountJob":2:{s:56:"\0App\\Queue\\UserAccount\\CreateUserAccountJob\0emailAddress";s:28:"DislikeLeash@BoatComics.test";s:54:"\0App\\Queue\\UserAccount\\CreateUserAccountJob\0successJob";O:41:"App\\Queue\\Candidate\\ConnectUserAccountJob":2:{s:58:"\0App\\Queue\\Candidate\\ConnectUserAccountJob\0userAccountUuid";N;s:56:"\0App\\Queue\\Candidate\\ConnectUserAccountJob\0candidateUuid";O:28:"Symfony\\Component\\Uid\\UuidV4":1:{s:6:"\0*\0uid";s:36:"eecdf048-75d9-4f26-bb37-e6d168a41006";}}}}';
    expect(
        () => phpDeserialize(serialized),
        throwsA(
            const TypeMatcher<ObjectWithoutDeserializationInformationFound>()));

    final envelope =
        phpDeserialize(serialized, knownClasses: symfonyExampleInformation)
            as SymfonyEnvelope;
    expect(envelope.stamps.first.runtimeType, SymfonyBusNameStamp);
    expect((envelope.stamps.first as SymfonyBusNameStamp).busName,
        'messenger.bus.default');
    expect(envelope.message.runtimeType, CreateUserAccount);
    final createUserAccount = envelope.message as CreateUserAccount;
    expect(createUserAccount.emailAddress, 'DislikeLeash@BoatComics.test');
    expect(createUserAccount.successJob?.candidateUuid?.uid,
        'eecdf048-75d9-4f26-bb37-e6d168a41006');
    expect(createUserAccount.successJob?.userAccountUuid, null);
  });
}

class SymfonyEnvelope {
  final List<StampInterface> stamps;
  final dynamic message;

  const SymfonyEnvelope(this.message, this.stamps);
}

class StampInterface {}

class SymfonyBusNameStamp implements StampInterface {
  final String busName;

  const SymfonyBusNameStamp(this.busName);
}

class CreateUserAccount {
  final String emailAddress;
  final ConnectUserAccountJob? successJob;

  const CreateUserAccount(this.emailAddress, [this.successJob]);
}

class ConnectUserAccountJob {
  final UuidV4? candidateUuid;
  final UuidV4? userAccountUuid;

  const ConnectUserAccountJob(this.candidateUuid, this.userAccountUuid);
}

class UuidV4 {
  final String uid;

  const UuidV4(this.uid);
}

final List<PhpSerializationObjectInformation> symfonyExampleInformation = [
  PhpSerializationObjectInformation(
    r'Symfony\Component\Messenger\Envelope',
    objectGenerator: (Map<String, dynamic> map) {
      final stamps = List<StampInterface>.from(
          map['\0Symfony\\Component\\Messenger\\Envelope\0stamps']
              ['Symfony\\Component\\Messenger\\Stamp\\BusNameStamp'],
          growable: false);

      return SymfonyEnvelope(
          map['\0Symfony\\Component\\Messenger\\Envelope\0message'], stamps);
    },
  ),
  PhpSerializationObjectInformation(
    r'Symfony\Component\Messenger\Stamp\BusNameStamp',
    objectGenerator: (Map<String, dynamic> map) => SymfonyBusNameStamp(
      map['\0Symfony\\Component\\Messenger\\Stamp\\BusNameStamp\0busName'],
    ),
  ),
  PhpSerializationObjectInformation(
    r'App\Queue\UserAccount\CreateUserAccountJob',
    objectGenerator: (Map<String, dynamic> map) => CreateUserAccount(
      map['\0App\\Queue\\UserAccount\\CreateUserAccountJob\0emailAddress'],
      map['\0App\\Queue\\UserAccount\\CreateUserAccountJob\0successJob'],
    ),
  ),
  PhpSerializationObjectInformation(
    r'App\Queue\Candidate\ConnectUserAccountJob',
    objectGenerator: (Map<String, dynamic> map) => ConnectUserAccountJob(
      map['\0App\\Queue\\Candidate\\ConnectUserAccountJob\0candidateUuid'],
      map['\0App\\Queue\\Candidate\\ConnectUserAccountJob\0userAccountUuid'],
    ),
  ),
  PhpSerializationObjectInformation(
    r'Symfony\Component\Uid\UuidV4',
    objectGenerator: (Map<String, dynamic> map) => UuidV4(
      map['\0*\0uid'],
    ),
  ),
];
