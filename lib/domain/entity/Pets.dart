
import 'package:flutter/material.dart';
import 'package:todo_app/Localization.dart';
import 'package:todo_app/domain/entity/Pet.dart';

// Available pets in app
class Pets {
  static List<Pet> getPetPrototypes() => [
    _PET_A,
    _PET_B,
  ];

  static Pet getPetPrototype(String key) {
    return getPetPrototypes().firstWhere((it) => it.key == key, orElse: () => Pet.INVALID);
  }

  static const _PET_A = const Pet(
    key: Pet.KEY_A,
    inactivePhase: PetPhase(
      flrPath: 'assets/ic_question.flr',
      sizeRatio: 0.55,
      alignment: Alignment.center,
      titleKey: AppLocalizations.UNKNOWN_PET_NAME,
      subtitleKey: AppLocalizations.PET_A_INACTIVE_SUBTITLE,
    ),
    eggPhase: PetPhase(
      flrPath: 'assets/pet_a_01.flr',
      sizeRatio: 0.6,
      alignment: Alignment.bottomCenter,
      maxExp: 10,
      titleKey: AppLocalizations.UNKNOWN_PET_EGG,
      subtitleKey: AppLocalizations.PET_A_EGG_SUBTITLE,
      notificationIconName: 'ic_egg',
    ),
    bornPhases: const [
      PetPhase(
        flrPath: 'assets/pet_a_01.flr',
        sizeRatio: 0.6,
        alignment: Alignment.bottomCenter,
        maxExp: 20,
        titleKey: AppLocalizations.PET_A_0_TITLE,
        subtitleKey: AppLocalizations.PET_A_0_SUBTITLE,
        notificationIconName: 'ic_pet',
      ),
      PetPhase(
        flrPath: 'assets/pet_a_01.flr',
        sizeRatio: 0.6,
        alignment: Alignment.bottomCenter,
        maxExp: 40,
        titleKey: AppLocalizations.PET_A_1_TITLE,
        subtitleKey: AppLocalizations.PET_A_1_SUBTITLE,
        notificationIconName: 'ic_pet',
      ),
      PetPhase(
        flrPath: 'assets/pet_a_01.flr',
        sizeRatio: 0.6,
        alignment: Alignment.bottomCenter,
        titleKey: AppLocalizations.PET_A_2_TITLE,
        subtitleKey: AppLocalizations.PET_A_2_SUBTITLE,
        notificationIconName: 'ic_pet',
      ),
    ],
  );

  static const _PET_B = const Pet(
    key: Pet.KEY_B,
    inactivePhase: PetPhase(
      flrPath: 'assets/ic_question.flr',
      sizeRatio: 0.55,
      alignment: Alignment.center,
      titleKey: AppLocalizations.UNKNOWN_PET_NAME,
      subtitleKey: AppLocalizations.PET_B_INACTIVE_SUBTITLE,
    ),
    eggPhase: PetPhase(
      flrPath: 'assets/pet_a_01.flr',
      sizeRatio: 0.6,
      alignment: Alignment.bottomCenter,
      maxExp: 20,
      titleKey: AppLocalizations.UNKNOWN_PET_EGG,
      subtitleKey: AppLocalizations.PET_B_EGG_SUBTITLE,
    ),
    bornPhases: const [
      PetPhase(
        flrPath: 'assets/pet_a_01.flr',
        sizeRatio: 0.6,
        alignment: Alignment.center,
        maxExp: 30,
        titleKey: AppLocalizations.PET_B_0_TITLE,
        subtitleKey: AppLocalizations.PET_B_0_SUBTITLE,
      ),
      PetPhase(
        flrPath: 'assets/pet_a_01.flr',
        sizeRatio: 0.7,
        alignment: Alignment.bottomCenter,
        maxExp: 50,
        titleKey: AppLocalizations.PET_B_1_TITLE,
        subtitleKey: AppLocalizations.PET_B_1_SUBTITLE,
      ),
      PetPhase(
        flrPath: 'assets/pet_a_01.flr',
        sizeRatio: 0.8,
        alignment: Alignment.bottomCenter,
        titleKey: AppLocalizations.PET_B_2_TITLE,
        subtitleKey: AppLocalizations.PET_B_2_SUBTITLE,
      ),
    ],
  );
}
