extends Node
class_name FilePaths

#-------------- Scenes --------------#
const PROJECTILE: String = "res://GameLoop/Projectile/Projectile.tscn"

const SPARKS: String = "res://GameLoop/VFX/HitFX/Sparks.tscn"
const HIT_RING: String = "res://GameLoop/VFX/HitFX/HitRing.tscn"
const RIPPLE: String = "res://GameLoop/VFX/DeathFX/Ripple.tscn"
const BURST: String = "res://GameLoop/VFX/DeathFX/Burst.tscn"
const DEBRIS_MANAGER: String = "res://GameLoop/VFX/DeathFX/DebrisManager.tscn"

const PLAYER: String = "res://GameLoop/Player/Player.tscn"

const UPGRADE_CARAVAN: String = "res://GameLoop/UpgradeCaravan/UpgradeCaravan.tscn"

const SCRAP: String = "res://GameLoop/Scrap.tscn"

const UPGRADE_MENU: String = "res://GUI/UpgradeMenu/UpgradeMenu.tscn"
const OPTIONS_MENU: String = "res://GUI/OptionsMenu/OptionsMenu.tscn"
const MAIN_ZONE: String = "res://GameLoop/Zone/MainZone.tscn"
const START_SCREEN: String = "res://GUI/StartScreen.tscn"

#-------------- SFX --------------#
const SOUND_HANDLER: String = "res://GameLoop/SFX/SoundHandler.tscn"

const SFX_COLLECT: String = "res://Assets/SFX/collect.wav"
const SFX_PLAYER_HURT: String = "res://Assets/SFX/playerhurt.mp3"
const SFX_PLAYER_FIRE: String = "res://Assets/SFX/playerfire.wav"
const SFX_ENEMY_FIRE: String = "res://Assets/SFX/enemyfire.wav"
const SFX_EXPLOSION1: String = "res://Assets/SFX/explosion1.wav"
const SFX_EXPLOSION2: String = "res://Assets/SFX/explosion2.wav"
const SFX_UPGRADE_REQUEST: String = "res://Assets/SFX/request.wav"
const SFX_UPGRADE_DENY: String = "res://Assets/SFX/requestdeny.wav"
const SFX_UPGRADE_READY: String = "res://Assets/SFX/upgradeready.wav"
const SFX_UPGRADE_ENTER: String = "res://Assets/SFX/upgradeenter.wav"
const SFX_UPGRADE_EXIT: String = "res://Assets/SFX/upgradeexit.wav"
const SFX_INSUFFICIENT: String = "res://Assets/SFX/insufficient.wav"
const SFX_CONFIRM: String = "res://Assets/SFX/confirm.wav"
const SFX_HIT: String = "res://Assets/SFX/hit.wav"

#-------------- Music --------------#
const MUSIC_TRACK_A: String = "res://Assets/Music/trackA.mp3"
const MUSIC_SPACE_TITLE: String = "res://Assets/Music/spacetitle.mp3"

#-------------- Resources --------------#
const PLAYER_PROJECTILE_DATA: String = "res://GameLoop/Projectile/ProjectileData/PlayerProjectile.tres"
const ENEMY_PROJECTILE_DATA: String = "res://GameLoop/Projectile/ProjectileData/EnemyProjectile.tres"

const BASE_PLAYER_PROJECTILE_DATA: String = "res://GameLoop/Projectile/ProjectileData/BasePlayerProjectile.tres"
const BASE_DAMAGE_ATTRIBUTE: String = "res://GameLoop/Player/Attributes/BaseAttributes/BaseDamage.tres"
const BASE_FIRERATE_ATTRIBUTE: String = "res://GameLoop/Player/Attributes/BaseAttributes/BaseFirerate.tres"
const BASE_PENETRATION_ATTRIBUTE: String = "res://GameLoop/Player/Attributes/BaseAttributes/BasePenetration.tres"
const BASE_PROJECTILE_ATTRIBUTE: String = "res://GameLoop/Player/Attributes/BaseAttributes/BaseProjectiles.tres"

const DEBRIS: String = "res://GameLoop/VFX/DeathFX/Debris.gd"
