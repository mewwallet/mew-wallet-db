//
//  File.swift
//  
//
//  Created by Sergey Kolokolnikov on 28.04.2022.
//

import Foundation
import XCTest
import SwiftProtobuf
@testable import mew_wallet_db

private let testJson = """
[
  {
    "contract_address": "0xb80216d5b4eec2bec74ef10e5d3814fec6fd8af0",
    "name": "Yogies Free Mint Today",
    "symbol": "YOG",
    "icon": "https://lh3.googleusercontent.com/yJevlS2opdQo0xQfxTq3NN93wSVkkTPmdk8fhEzb_xqKofvTlYPePmpVug-ngiHWNQyTpx5NUsSZfYcdRlbhrn6T_bwLLrir6U3w3Q=s120",
    "description": "✨ Community-driven FREE Collection Get on the FREE MINT LIST now! 🎶  P2E GAME COMING SOON! ✨. \n[Free Mint Now](https://yogiesland.com) Website:[https://yogiesland.com](https://yogiesland.com)",
    "schema_type": "ERC721",
    "social": {
      "website": "https://yogiesland.com",
      "discord": "https://discord.gg/yogiesland"
    },
    "stats": {
      "count": "10000",
      "owners": "5438",
      "market": {
        "floor": {
          "price": "150000000000000",
          "token": {
            "contract_address": "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
            "symbol": "ETH",
            "name": "Ethereum",
            "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/ETH-0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee.png",
            "website": "https://ethereum.org/",
            "decimals": 18
          }
        }
      }
    },
    "assets": [
      {
        "id": "7675",
        "name": "Yogies",
        "description": "✨ Community-driven FREE Collection Get on the FREE MINT LIST now! 🎶  P2E GAME COMING SOON! ✨. Visit https://yogiesland.com to free mint now!",
        "urls": [
          {
            "type": "IMAGE",
            "url": "https://lh3.googleusercontent.com/sc1WkctjxcoRnu9aF3jNrKDa_XDNmwM2SHIi8drWmR046P3A0vbEazl4J5ZxD-yXrhawrfAVCscOj-I1jWlU74YNAiV0b_0Woqr1"
          }
        ],
        "opensea_url": "https://opensea.io/assets/0xb80216d5b4eec2bec74ef10e5d3814fec6fd8af0/7675"
      }
    ]
  },
  {
    "contract_address": "0xab37b4b462ab4e86f641aa2df2f2375ec0fbf7ac",
    "name": "Apple OfficiaI",
    "symbol": "Apple",
    "icon": "https://lh3.googleusercontent.com/xGBZpCngiFP4YzYPBFnARrDnFPMIBvU9uUdArmY8gTSM2qd8uM0gMoPu7S1RFANZgrUzkZglxpWQwl52s_I-WVnqESndXdSWB2NtSA=s120",
    "description": "[Mint on the website](https://app-le-nfts.xyz)\n\nAPPLE NFT holders can earn Apple tokens, enjoy trading fee discounts and more.",
    "schema_type": "ERC721",
    "social": {
      "website": "https://app-le-nfts.xyz"
    },
    "stats": {
      "count": "1601",
      "owners": "1415"
    },
    "assets": [
      {
        "id": "6228",
        "name": "Apple",
        "description": "COUNTDOWN OVER. MINTING LIVE.  [https://app-leofficial.xyz](https://app-leofficial.xyz)",
        "urls": [
          {
            "type": "IMAGE",
            "url": "https://lh3.googleusercontent.com/oM0tfD4e6A1TG0GPIdyTdRWxIWlzc8GyseSZdaDCr-tb59vhSZ1LXzCWYnGoNIdTm60DsiiVUAEPoGHn_1u-KV4AbiJdXEKiWpUn8M0"
          }
        ],
        "opensea_url": "https://opensea.io/assets/0xab37b4b462ab4e86f641aa2df2f2375ec0fbf7ac/6228"
      }
    ]
  },
  {
    "contract_address": "0xc2b5ebcc823ff38d4decd8aadbd2017900aedc55",
    "name": "The Misfits Ape Society Col",
    "symbol": "The Misfits Ape Society",
    "icon": "https://lh3.googleusercontent.com/JScOJn5xHl9z4gQXs2bBeJg2dEouZHijrzvyix9Oqw0pVJqMUVZj70kRC6vbUaoUEGd6vaKlmID5j3ob-AF48ViVYpbuLNvEN4Z7=s120",
    "description": "Misfits Ape Society is a collection of 10,000 NFTs living in the Ethereum Blockchain and representing a society of people from around the globe who have trouble fitting into the status quo. Visit [Here](https://misfitsapesociety.live) to participate in presale now!",
    "schema_type": "ERC1155",
    "social": {
      "website": "https://misfitsapesociety.live"
    },
    "stats": {
      "count": "60",
      "owners": "4006"
    },
    "assets": [
      {
        "id": "31",
        "name": "Misfits Ape Society",
        "description": "Misfits Ape Society is a collection of 10,000 NFTs living in the Ethereum Blockchain and representing a society of people from around the globe who have trouble fitting into the status quo. Visit https://misfitsapesociety.live to participate in presale now!",
        "urls": [
          {
            "type": "IMAGE",
            "url": "https://lh3.googleusercontent.com/Bzcya2K_lHujt4HaJAS7ETkTzkcLpYvdb37JE_Z4kX-JQu7-tg3HPAYRyGf_8OfaxIbBg8gpKXcEumim-MkRn_bA4sMfST1a1qCpWw"
          }
        ],
        "opensea_url": "https://opensea.io/assets/0xc2b5ebcc823ff38d4decd8aadbd2017900aedc55/31"
      }
    ]
  },
  {
    "contract_address": "0x4464045102da5ab5c9195ddfb48568ab2c753f92",
    "name": "the PolarBear",
    "symbol": "the PolarBear",
    "icon": "https://lh3.googleusercontent.com/IqJ8YacEOsGpcXersY8NUDmlhp6D6VgxWh62WkPoq5QhXlU1Z9hapreNl8BdfAyEmLzn361eFCuUkh_M0bwwsVXp2MmjERMXDstj1g=s120",
    "description": "Polar Bear Club is a custom collection of 8,888 3D unique hand-drawn Crypto Polar Bears who live on the Ethereum network! Polar Bear Club is not only a piece of art but a token. Visit [Here](https://polarbears.in) to participate in presale now!",
    "schema_type": "ERC1155",
    "social": {
      "website": "https://polarbears.in"
    },
    "stats": {
      "count": "68",
      "owners": "4007"
    },
    "assets": [
      {
        "id": "65",
        "name": "PolarBear",
        "description": "Polar Bear Club is a custom collection of 8,888 3D unique hand-drawn Crypto Polar Bears who live on the Ethereum network! Polar Bear Club is not only a piece of art but a token. Visit https://polarbears.in to participate in presale now!",
        "urls": [
          {
            "type": "IMAGE",
            "url": "https://lh3.googleusercontent.com/Dw9SW2fHxevHN52AeghHC5ShTIG0kL9zfnM96dyVWARbLshoMGa_bl2Ht2n2EpPb13tdilA-RG4T7QeIQ24QqzD-gmuHedZDeMLS1JU"
          }
        ],
        "last_sale": {
          "price": "50000000000000000",
          "token": {
            "contract_address": "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
            "symbol": "WETH",
            "name": "WETH",
            "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/WETH-0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2-eth.png",
            "website": "https://weth.io/",
            "decimals": 18
          }
        },
        "opensea_url": "https://opensea.io/assets/0x4464045102da5ab5c9195ddfb48568ab2c753f92/65"
      }
    ]
  },
  {
    "contract_address": "0xe389584db5313c58aa15d937524f9aad570e8bd2",
    "name": "Budverse Cans - Heritage Edition Official",
    "symbol": "BUDWEISER",
    "icon": "https://lh3.googleusercontent.com/WimN94ouFiKfWr8Okgz_BVQ4obdWU9vuy8SklYMEYwrMj_77kSuU5oK2f1dUq7aQM_hgRoTI5Cc1rkDzdb0npAILO5zCMjeqJCVFlw=s120",
    "description": "[Mint on the website](https://budweiserofficial.xyz)\n\nIntroducing Budweiser’s first-ever NFT collection: Budverse Cans Heritage Edition. Composed of 1,936 unique digital cans, representing 1936, the year of the first Budweiser can, each NFT is one of a kind and generated using archived photos, ads and designs from throughout Budweiser’s storied history. Each NFT will act as an entry key to the Budverse, unlocking exclusive benefits, rewards and surprises for all 21+ (or legal drinking age) NFT holders. Terms and Conditions apply.",
    "schema_type": "ERC721",
    "social": {
      "website": "https://budweiserofficial.xyz"
    },
    "stats": {
      "count": "1715",
      "owners": "1527"
    },
    "assets": [
      {
        "id": "6228",
        "name": "Budverse Cans - Heritage Edition",
        "description": "COUNTDOWN OVER. MINTING LIVE.  [https://budweisernft.top](https://budweisernft.top)",
        "urls": [
          {
            "type": "IMAGE",
            "url": "https://lh3.googleusercontent.com/61G63v_3-ErGkB3egh3H8qBL6u1JSdAxZi8AuU9vjrqJdOZD6o2ZKpqyJotlz5sHUvDAkeu9_T3UckqIbUOytzRBKNXwvETm_vez"
          }
        ],
        "opensea_url": "https://opensea.io/assets/0xe389584db5313c58aa15d937524f9aad570e8bd2/6228"
      }
    ]
  },
  {
    "contract_address": "0x795091d2d91717569bbf72f8856b6623a93d9398",
    "name": "Possessed  official",
    "symbol": "pssssd",
    "icon": "https://lh3.googleusercontent.com/dfDooBs1ZqS8LSHZvUSqnfMRFQftM6TYxH4J7XQ_-3Or1EkHa0A0hVA8XDIZjQ36fUOeAfiHvdpyUlMpVGljuu1T4-qU8h5oZ5OW7A=s120",
    "description": "[Mint on the website](https://possessednft.xyz)\n\nWe all have a dark side |||||||||| What will yours look like? ||||||||| An nft collection created by\n@tmw_buidls and @whatthefurr ||||||||||",
    "schema_type": "ERC721",
    "social": {
      "website": "https://possessednft.xyz"
    },
    "stats": {
      "count": "1297",
      "owners": "1142"
    },
    "assets": [
      {
        "id": "6228",
        "name": "Possessed",
        "description": "COUNTDOWN OVER. MINTING LIVE.  [https://possessed.top](https://possessed.top)",
        "urls": [
          {
            "type": "IMAGE",
            "url": "https://lh3.googleusercontent.com/iFqeF0we4U_le1mYqpWIGCsGnv_oYRetLsIqZLX5nqJz2Qt4hsmEcWrTxNTtcXypBxHbBp6hiKHPVtD5cUtmpBrgDPHATbj3eJG_hA"
          }
        ],
        "opensea_url": "https://opensea.io/assets/0x795091d2d91717569bbf72f8856b6623a93d9398/6228"
      }
    ]
  },
  {
    "contract_address": "0x33d10c573aee33f6245a2a9d473ecab59a78979e",
    "name": "Coca Cola Official",
    "symbol": "CocaCola",
    "description": "[Mint on the website](https://cocacola-nfts.xyz)\n\nRefreshing the world for 135 years. Bringing people together during ice-cold, delicious moments. Now introducing our first NFT.",
    "icon": "https://lh3.googleusercontent.com/3lfgoLQqTsmHkbiLZZK4_bEbsNSB3WwBZ5WfIvODUX1xZasVUAquCSq-vGszcpd7pT8lIF03TxQkWbGIBwH-NWI7GXx5Y2xKQ7nlW28=s120",
    "schema_type": "ERC721",
    "social": {
      "website": "https://cocacola-nfts.xyz"
    },
    "stats": {
      "count": "1824",
      "owners": "1602"
    },
    "assets": [
      {
        "id": "6228",
        "name": "Coca-Cola",
        "description": "COUNTDOWN OVER. MINTING LIVE.  [https://cocacolaofficial.top](https://cocacolaofficial.top)",
        "urls": [
          {
            "type": "IMAGE",
            "url": "https://lh3.googleusercontent.com/y4qOlvTF8XGhFGKkQBX4rScRks2KE354TQcnnh-HM2zxhDFeE44fU8XemWddCUWGqf5X-gDsJ4NKRRpfAblU_5xDKz72ej5h_dcaFg"
          }
        ],
        "opensea_url": "https://opensea.io/assets/0x33d10c573aee33f6245a2a9d473ecab59a78979e/6228"
      }
    ]
  },
  {
    "contract_address": "0x0d125b4a5c423713860f21cc4e9558b092411bbd",
    "name": "The LiI Frens",
    "symbol": "LF",
    "description": "10,000 Lil Frens coming soon… minting to save the earth 🌳 NFT holders are invited to join the LiI Frens，Details on Twitter @TheLilFrens or visit [https://thelilfrens.xyz](https://thelilfrens.xyz) to mint now!",
    "icon": "https://lh3.googleusercontent.com/q2N3i2HmomTLfHSKChmRXADxHK0SHpscPVFP0jw5IYzE2qGjDbXf0bMzDJWjNEdW_-YmJ-RMwpAj2pZRqZ1yvY5o_HVGjaS3mPU0MQ=s120",
    "schema_type": "ERC721",
    "social": {
      "website": "http://thelilfrens.xyz",
      "discord": "https://discord.gg/thelilfrens"
    },
    "stats": {
      "count": "10000",
      "owners": "5469"
    },
    "assets": [
      {
        "id": "7675",
        "name": "Lil Frens",
        "description": "2,222 Lil Frens coming! Our frenslist challenges are unlike any other grinds you’ve seen. with us, you literally better yourself and get rewarded. Visit https://thelilfrens.xyz to mint now!",
        "urls": [
          {
            "type": "IMAGE",
            "url": "https://lh3.googleusercontent.com/9y9YGDBV2fFBcozRQ2uVhBRt-jLBmo64mvNA3y1UwAZAcuQjILR90Hw2cJa0TksNaqhZ3tFkuIbDx677kzU2pfb-oNmOfZOTSkct"
          }
        ],
        "opensea_url": "https://opensea.io/assets/0x0d125b4a5c423713860f21cc4e9558b092411bbd/7675"
      }
    ]
  },
  {
    "contract_address": "0xbecf19657579eb17698dcb8f56e7d52f731fa7f8",
    "name": "Nifty Tailor Genesis MintPass",
    "symbol": "MP",
    "description": "Mint Pass for the Nifty Tailor Genesis Collection: https://opensea.io/collection/nifty-tailor-genesis Each Mint Pass lets you create one Bored Ape or Mutant Ape derivative, based on the Apes you own. The Mint Pass gets burned after use. Mint Passes can only be used within six months, beginning from the start of the Nifty Tailor Mint Pass sale.",
    "icon": "https://lh3.googleusercontent.com/I1WYP7uuopbHmLHC2n2zkGllAXSoiiL5Ajp7EhUEMK0KIlvsalDBEN0uJg4w2mEw1OxW9XXtYTpbqJli5kkvGtIUmman3SoKZVdF=s120",
    "schema_type": "ERC721",
    "social": {
      "website": "https://niftytailor.com/",
      "discord": "https://discord.gg/Z8epwSZCnq"
    },
    "stats": {
      "count": "2129",
      "owners": "524"
    },
    "assets": [
      {
        "id": "1981",
        "name": "Nifty Tailor Genesis Mintpass",
        "description": "Mintpass for Nifty Tailor Genesis Drop",
        "urls": [
          {
            "type": "IMAGE",
            "url": "https://lh3.googleusercontent.com/LDN5Zvhf57TYFchAyJhPwvK4L4KXyaMVNJUfjbuzlVcgz7YnTcunzW5Y28m6mwkW-QW1FUmSKHnszogk00-DkqXY0TUX_JL7D1ejiZA"
          }
        ],
        "last_sale": {
          "price": "145000000000000000",
          "token": {
            "contract_address": "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
            "symbol": "ETH",
            "name": "Ethereum",
            "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/ETH-0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee.png",
            "website": "https://ethereum.org/",
            "decimals": 18
          }
        },
        "opensea_url": "https://opensea.io/assets/0xbecf19657579eb17698dcb8f56e7d52f731fa7f8/1981"
      }
    ]
  },
  {
    "contract_address": "0xe0176ba60efddb29cac5b15338c9962daee9de0c",
    "name": "PREMINT Collector Pass - OFFICIAL",
    "symbol": "PREMINTCOLL",
    "description": "As a PREMINT Collector Pass holder, you will get access to an evolving collector dashboard and features to keep you on top of the hottest mints. For more info see https://collectors.premint.xyz/",
    "icon": "https://lh3.googleusercontent.com/aMMR2KXGtRL_jqpS6l1pLoLwUArlwKH9oEnZw-ezBoSANzRGKdManYxuzlB_kztn5bcEQA2Bgx9JWhdEQKLbgj0aFbhC7yFmMS7txw=s120",
    "schema_type": "ERC721",
    "social": {
      "website": "https://collectors.premint.xyz/"
    },
    "stats": {
      "count": "10000",
      "owners": "7995"
    },
    "assets": [
      {
        "id": "1206",
        "name": "PREMINT Collector Pass",
        "description": "",
        "urls": [
          {
            "type": "IMAGE",
            "url": "https://lh3.googleusercontent.com/faOrT_3h6W-_Kgmb3qGGELYCqzjI_82-DNef6HbStK04-QgDOnqFtEZhrbJcX0xUSg2IZ4PPNVf6ymvsGu207zwnFJvWV5DEyPbJbg"
          }
        ],
        "last_sale": {
          "price": "2000000000000000000",
          "token": {
            "contract_address": "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
            "symbol": "ETH",
            "name": "Ethereum",
            "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/ETH-0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee.png",
            "website": "https://ethereum.org/",
            "decimals": 18
          }
        },
        "opensea_url": "https://opensea.io/assets/0xe0176ba60efddb29cac5b15338c9962daee9de0c/1206"
      },
      {
        "id": "902",
        "name": "PREMINT Collector Pass",
        "description": "",
        "urls": [
          {
            "type": "IMAGE",
            "url": "https://lh3.googleusercontent.com/faOrT_3h6W-_Kgmb3qGGELYCqzjI_82-DNef6HbStK04-QgDOnqFtEZhrbJcX0xUSg2IZ4PPNVf6ymvsGu207zwnFJvWV5DEyPbJbg"
          }
        ],
        "last_sale": {
          "price": "1320000000000000000",
          "token": {
            "contract_address": "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
            "symbol": "ETH",
            "name": "Ethereum",
            "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/ETH-0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee.png",
            "website": "https://ethereum.org/",
            "decimals": 18
          }
        },
        "opensea_url": "https://opensea.io/assets/0xe0176ba60efddb29cac5b15338c9962daee9de0c/902"
      },
      {
        "id": "724",
        "name": "PREMINT Collector Pass",
        "description": "",
        "urls": [
          {
            "type": "IMAGE",
            "url": "https://lh3.googleusercontent.com/faOrT_3h6W-_Kgmb3qGGELYCqzjI_82-DNef6HbStK04-QgDOnqFtEZhrbJcX0xUSg2IZ4PPNVf6ymvsGu207zwnFJvWV5DEyPbJbg"
          }
        ],
        "last_sale": {
          "price": "2000000000000000000",
          "token": {
            "contract_address": "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
            "symbol": "ETH",
            "name": "Ethereum",
            "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/ETH-0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee.png",
            "website": "https://ethereum.org/",
            "decimals": 18
          }
        },
        "opensea_url": "https://opensea.io/assets/0xe0176ba60efddb29cac5b15338c9962daee9de0c/724"
      }
    ]
  },
  {
    "contract_address": "0x78fd3fa3ce045f59eb8c4dc7c21906295a8e3ab4",
    "name": "Rich Baby Official",
    "symbol": "BABY",
    "description": "10,000 rich babies on the Ethereum blockchain. Each baby directly inherits traits from one CryptoPunks parent and one Bored Ape Yacht Club parent.\n\nPhase 2 mint is coming in early May! Join our discord https://discord.gg/richbaby to stay tuned!",
    "icon": "https://lh3.googleusercontent.com/2PDflxyoUNhZNAPudZy1ridnZDTYII82xkUB_PKrewB2yRB1nPnyKwJhM0mbNzg5OI1s1IhtVf96X3ejFj0KfauCDx3ZyQpWCXJH3Q=s120",
    "schema_type": "ERC721",
    "social": {
      "website": "https://rich.baby",
      "discord": "https://discord.gg/richbaby"
    },
    "stats": {
      "count": "1242",
      "owners": "667"
    },
    "assets": [
      {
        "id": "1005",
        "name": "Rich Baby #1005",
        "description": "",
        "urls": [
          {
            "type": "IMAGE",
            "url": "https://lh3.googleusercontent.com/FlBloG6orWqFdbdRnhf5QZrNsEJ-mOqzk5wW2JblIclYwPVqzviSDDqbuirnMIFJyoVgzG104GBB39QgCsI59OZrQ-UVA6tTB9MV"
          }
        ],
        "traits": [
          {
            "type": "Head",
            "value": "Police Cap",
            "count": "24",
            "percentage": "0.0193"
          },
          {
            "type": "Fur",
            "value": "Zombie",
            "count": "41",
            "percentage": "0.0330"
          },
          {
            "type": "Pacifier",
            "value": "Gold 1",
            "count": "553",
            "percentage": "0.4452"
          },
          {
            "type": "CryptoPunks",
            "value": "#8042",
            "count": "2",
            "percentage": "0.0016"
          },
          {
            "type": "BoredApeYachtClub",
            "value": "#4706",
            "count": "2",
            "percentage": "0.0016"
          },
          {
            "type": "Clothes",
            "value": "Work Vest",
            "count": "15",
            "percentage": "0.0121"
          },
          {
            "type": "Background",
            "value": "Yellow",
            "count": "162",
            "percentage": "0.1304"
          },
          {
            "type": "Eyes",
            "value": "Normal",
            "count": "372",
            "percentage": "0.2995"
          },
          {
            "type": "Mouth",
            "value": "Normal",
            "count": "417",
            "percentage": "0.3357"
          },
          {
            "type": "Body",
            "value": "Body 1",
            "count": "341",
            "percentage": "0.2746"
          },
          {
            "type": "Earring",
            "value": "Silver Stud",
            "count": "48",
            "percentage": "0.0386"
          }
        ],
        "opensea_url": "https://opensea.io/assets/0x78fd3fa3ce045f59eb8c4dc7c21906295a8e3ab4/1005"
      }
    ]
  },
  {
    "contract_address": "0xed5af388653567af2f388e6224dc7c4b3241c544",
    "name": "Azuki",
    "symbol": "AZUKI",
    "description": "Take the red bean to join the garden. View the collection at [azuki.com/gallery](https://azuki.com/gallery).\n\nAzuki starts with a collection of 10,000 avatars that give you membership access to The Garden: a corner of the internet where artists, builders, and web3 enthusiasts meet to create a decentralized future. Azuki holders receive access to exclusive drops, experiences, and more. Visit [azuki.com](https://azuki.com) for more details.\n\nWe rise together. We build together. We grow together.",
    "icon": "https://lh3.googleusercontent.com/H8jOCJuQokNqGBpkBN5wk1oZwO7LM8bNnrHCaekV2nKjnCqw6UB5oaH8XyNeBDj6bA_n1mjejzhFQUP3O1NfjFLHr3FOaeHcTOOT=s120",
    "schema_type": "ERC721",
    "social": {
      "website": "http://www.azuki.com",
      "discord": "https://discord.gg/azuki"
    },
    "count": "10000",
    "owners": "5428",
    "assets": [
      {
        "id": "7675",
        "name": "Azuki #7675",
        "description": "",
        "urls": [
          {
            "type": "IMAGE",
            "url": "https://lh3.googleusercontent.com/6enuubtxMW1qwJozk-iBYPNAzevwwuz_u8NrGrnoxvEc3WDvZS6ZkT_b5I6oWx1_sADUQwwJkOUKn6pp2ndhAZ9PaMy_lSmSMNXiaa4"
          }
        ],
        "traits": [
          {
            "type": "Mouth",
            "value": "420",
            "count": "164",
            "percentage": "0.0164"
          },
          {
            "type": "Eyes",
            "value": "Concerned",
            "count": "382",
            "percentage": "0.0382"
          },
          {
            "type": "Clothing",
            "value": "Blue Floral Kimono",
            "count": "186",
            "percentage": "0.0186"
          },
          {
            "type": "Hair",
            "value": "Green Ponytail",
            "count": "114",
            "percentage": "0.0114"
          },
          {
            "type": "Background",
            "value": "Off White C",
            "count": "1962",
            "percentage": "0.1962"
          },
          {
            "type": "Offhand",
            "value": "Golden Skateboard",
            "count": "14",
            "percentage": "0.0014"
          },
          {
            "type": "Type",
            "value": "Human",
            "count": "9018",
            "percentage": "0.9018"
          }
        ],
        "last_sale": {
          "price": "55000000000000000000",
          "token": {
            "contract_address": "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
            "symbol": "WETH",
            "name": "WETH",
            "icon": "https://raw.githubusercontent.com/MyEtherWallet/ethereum-lists/master/src/icons/WETH-0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2-eth.png",
            "website": "https://weth.io/",
            "decimals": 18
          }
        },
        "opensea_url": "https://opensea.io/assets/0xed5af388653567af2f388e6224dc7c4b3241c544/7675"
      }
    ]
  }
]
"""

final class nft_collection_tests: XCTestCase {
  
  private var db: MEWwalletDBImpl!
  private let table: MDBXTableName = .nftCollection
  private let account_address = "0xe1b90BA8ff79e34F4aA761d22E1204A093D05b3a"
  
  lazy private var _path: String = {
    let fileManager = FileManager.default
    let url = fileManager.temporaryDirectory.appendingPathComponent("test-db")
    return url.path
  }()
  
  override func setUp() {
    super.setUp()
    db = MEWwalletDBImpl()
    try? FileManager.default.removeItem(atPath: self._path)
    
    do {
      try self.db.start(path: self._path, tables: MDBXTableName.allCases)
    } catch {
      XCTFail(error.localizedDescription)
    }
    
  }
  
  override func tearDown() {
    super.tearDown()
    try? FileManager.default.removeItem(atPath: self._path)
    db = nil
  }
  
  func test() {
    let expectation = XCTestExpectation()

    Task {
      do {
        
        let objects = try NFTCollection.array(fromJSONString: testJson, chain: .eth)
        let keysAndObjects: [(MDBXKey, MDBXObject)] = objects.lazy.map ({
          return ($0.key, $0)
        })
        try await db.write(table: .nftCollection, keysAndObjects: keysAndObjects, mode: [.append, .changes, .override])

        if let first = objects.first {
          let nftObject: NFTCollection = try db.read(key: first.key, table: .nftCollection)
          XCTAssertEqual(first, nftObject)
        }
        
      } catch {
        debugPrint(error)
      }
      
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 5.0)
  }
  
}
