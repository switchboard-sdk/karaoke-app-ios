//
//  SongListData.swift
//  KaraokeApp
//
//  Created by Iván Nádor on 2023. 08. 14..
//

import Foundation

struct Song {
    let path: String
    let displayName: String
    let lyrics: String
    let duration: String

    static let songListData: [Song] = [
        Song(
            path: Bundle.main.url(forResource: "House_of_the_Rising_Sun", withExtension: "mp3")!.absoluteString,
            displayName: "House of the Rising Sun",
            lyrics: house_lyrics,
            duration: "4m 20s"
        ),
        Song(
            path: Bundle.main.url(forResource: "Amazing_Grace", withExtension: "mp3")!.absoluteString,
            displayName: "Amazing Grace",
            lyrics: amazing_grace_lyrics,
            duration: "3m 01s"
        ),
        Song(
            path: Bundle.main.url(forResource: "La_Bamba", withExtension: "mp3")!.absoluteString,
            displayName: "La Bamba",
            lyrics: la_bamba_lyrics,
            duration: "2m 19s"
        )
    ]

    private static let house_lyrics = "There is a house way down in New Orleans\n" +
            "They call the Rising Sun\n" +
            "And it's been the ruin of many a poor boy\n" +
            "And God I know I'm one\n" +
            "Mother was a tailor, yeah, yeah\n" +
            "Sewed my Levi jeans\n" +
            "My father was a gamblin' man, yeah, yeah\n" +
            "Down, way down in New Orleans\n" +
            "Now the only thing a gamblin' man ever needs\n" +
            "Is a suitcase, Lord, and a trunk\n" +
            "And the only time a fool like him is satisfied\n" +
            "Is when he's all stone cold drunk"

    private static let amazing_grace_lyrics  = "Amazing grace how sweet the sound\n" +
            "That saved a wretch like me\n" +
            "I once was lost, but now I'm found\n" +
            "Was blind but now I see\n" +
            "'Twas grace that taught my heart to fear\n" +
            "And grace my fears relieved\n" +
            "How precious did that grace appear\n" +
            "The hour I first believed\n" +
            "Through many dangers, toils, and snares\n" +
            "I have already come\n" +
            "This grace that brought me safe thus far\n" +
            "And grace will lead me home\n" +
            "When we've been here ten thousand years\n" +
            "Bright, shining as the sun\n" +
            "We've no less days to sing God's praise\n" +
            "Than when we first begun\n" +
            "Amazing grace how sweet the sound\n" +
            "That saved a wretch like me\n" +
            "I once was lost, but now I'm found\n" +
            "Was blind but now I see"

    private static let la_bamba_lyrics  = "Para bailar la bamba\n" +
            "Para bailar la bamba se necesita una poca de gracia\n" +
            "Una poca de gracia pa' mi pa' ti y arriba y arriba\n" +
            "Ah y arriba y arriba por ti seré, por ti seré, por ti seré\n" +
            "Yo no soy marinero\n" +
            "Yo no soy marinero, soy capitán,\n" +
            "Soy capitán, soy capitán\n" +
            "Bamba bamba...\n" +
            "Para bailar la bamba\n" +
            "Para bailar la bamba se necesita una poca de gracia\n" +
            "Una poca de gracia pa' mi pa' ti ah y arriba y arriba\n" +
            "Para bailar la bamba\n" +
            "Para bailar la bamba se necesita una poca de gracia\n" +
            "Una poca de gracia pa' mi pa' ti ah y arriba y arriba\n" +
            "Ah y arriba y arriba por ti seré, por ti seré, por ti seré\n" +
            "Bamba bamba..."
}
