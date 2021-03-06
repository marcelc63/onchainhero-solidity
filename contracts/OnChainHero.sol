pragma solidity ^0.8.0;

// We need some util functions for strings.
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

// We need to import the helper functions from the contract that we copy/pasted.
import { Base64 } from "./libraries/Base64.sol";

contract OnChainHero is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  event NewEpicNFTMinted(address sender, uint256 tokenId);

  constructor() ERC721("OnChainHero", "HERO") {
    console.log("This is my NFT contract. Woah!");
  }

  function _uint2str(uint256 _i) internal pure returns (string memory str) {
    if (_i == 0) {
      return "0";
    }
    uint256 j = _i;
    uint256 length;
    while (j != 0) {
      length++;
      j /= 10;
    }
    bytes memory bstr = new bytes(length);
    uint256 k = length;
    j = _i;
    while (j != 0) {
      bstr[--k] = bytes1(uint8(48 + (j % 10)));
      j /= 10;
    }
    str = string(bstr);
  }

  function pickRandomBgColor(uint256 tokenId)
    public
    view
    returns (string memory)
  {
    uint256 rand = random(
      string(abi.encodePacked("BG_COLOR", Strings.toString(tokenId)))
    );
    rand = rand % bgColors.length;
    return bgColors[rand];
  }

  function pickRandomCardColor(uint256 tokenId)
    public
    view
    returns (string memory)
  {
    uint256 rand = random(
      string(abi.encodePacked("CARD_COLOR", Strings.toString(tokenId)))
    );
    rand = rand % cardColors.length;
    return cardColors[rand];
  }

  function pickRandomNoun(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(
      string(abi.encodePacked("NOUN", Strings.toString(tokenId)))
    );
    rand = rand % nouns.length;
    return nouns[rand];
  }

  function pickRandomPrefix(uint256 tokenId)
    public
    view
    returns (string memory)
  {
    uint256 rand = random(
      string(abi.encodePacked("PREFIX", Strings.toString(tokenId)))
    );
    rand = rand % prefixes.length;
    return prefixes[rand];
  }

  function pickRandomPower(uint256 tokenId)
    public
    view
    returns (string memory)
  {
    uint256 rand = random(
      string(abi.encodePacked("POWER", Strings.toString(tokenId)))
    );
    rand = rand % powers.length;
    return powers[rand];
  }

  function pickRandomLocation(uint256 tokenId)
    public
    view
    returns (string memory)
  {
    uint256 rand = random(
      string(abi.encodePacked("LOCATION", Strings.toString(tokenId)))
    );
    rand = rand % locations.length;
    return locations[rand];
  }

  function pickRandomGrade(uint256 tokenId)
    public
    view
    returns (string memory)
  {
    uint256 rand = random(
      string(abi.encodePacked("GRADE", Strings.toString(tokenId)))
    );
    rand = rand % grades.length;
    return grades[rand];
  }

  function random(string memory input) internal pure returns (uint256) {
    return uint256(keccak256(abi.encodePacked(input)));
  }

  // Main function
  function makeAnEpicNFT() public {
    uint256 newItemId = _tokenIds.current();

    string memory cardColor = pickRandomCardColor(newItemId);
    string memory heroName = string(
      abi.encodePacked(
        pickRandomPrefix(newItemId),
        " ",
        pickRandomNoun(newItemId)
      )
    );

    string memory finalSvgOne = string(
      abi.encodePacked(svgPartOne, pickRandomBgColor(newItemId), svgPartTwo)
    );
    string memory finalSvgTwo = string(
      abi.encodePacked(cardColor, svgPartThree, pickRandomGrade(newItemId))
    );
    string memory finalSvgThree = string(
      abi.encodePacked(svgPartFour, _uint2str(newItemId))
    );
    string memory finalSvgFour = string(
      abi.encodePacked(svgPartFive, heroName, svgPartSix)
    );
    string memory finalSvgFive = string(
      abi.encodePacked(
        pickRandomPower(newItemId),
        svgPartSeven,
        pickRandomLocation(newItemId)
      )
    );
    string memory finalSvgSix = string(
      abi.encodePacked(svgPartEight, cardColor, svgPartNine)
    );

    string memory finalSvg = string(
      abi.encodePacked(
        finalSvgOne,
        finalSvgTwo,
        finalSvgThree,
        finalSvgFour,
        finalSvgFive,
        finalSvgSix
      )
    );

    console.log(finalSvg);
    string memory jsonOne = string(
      abi.encodePacked(
        '{"name": "OnChainHero #',
        _uint2str(newItemId),
        '", "description": "Hero License for '
      )
    );
    string memory jsonTwo = string(
      abi.encodePacked(
        heroName,
        ' issued by the OnChainHero Corps.", "image": "data:image/svg+xml;base64,',
        Base64.encode(bytes(finalSvg)),
        '"}'
      )
    );
    // Get all the JSON metadata in place and base64 encode it.
    string memory json = Base64.encode(
      bytes(string(abi.encodePacked(jsonOne, jsonTwo)))
    );

    // Just like before, we prepend data:application/json;base64, to our data.
    string memory finalTokenUri = string(
      abi.encodePacked("data:application/json;base64,", json)
    );

    console.log(finalTokenUri);

    _safeMint(msg.sender, newItemId);

    // Update your URI!!!
    _setTokenURI(newItemId, finalTokenUri);

    _tokenIds.increment();
    console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

    emit NewEpicNFTMinted(msg.sender, newItemId);
  }

  // TODO: make this svg to be named properly instead of ordered. Ordered
  // naming makes it hard for us to add things in the middle.
  // This is our SVG code. All we need to change is the word that's displayed. Everything else stays the same.
  // So, we make a baseSvg variable here that all our NFTs can use.
  // We split the SVG at the part where it asks for the background color.
  string constant svgPartOne =
    "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base,.label,.number{fill:#777;font-family:Monaco,sans-serif;font-size:8px}.base,.label{font-size:10px}.base{fill:#222;font-size:12px;font-weight:600}</style><rect width='100%' height='100%' fill='";
  string constant svgPartTwo = "'/><rect width='90%' height='60%' fill='";
  string constant svgPartThree =
    "' x='5%' y='20%' rx='20' style='-webkit-filter:drop-shadow(0 0 10px rgba(0,0,0,.5))' filter='drop-shadow(0 0 10px rgba(0,0,0,.5))'/><rect width='88%' height='58%' fill='#fff' x='6%' y='21%' rx='18'/><g><circle style='fill:url(#toning);stroke:#010101;stroke-width:1.6871;stroke-miterlimit:10;' cx='85%' cy='30%' r='5%'></circle><text x='85%' y='30%' text-anchor='middle' dy='.3em'>";
  string constant svgPartFour =
    "</text></g><text x='10%' y='30%' class='base' dominant-baseline='middle'>Super Hero License</text><text x='10%' y='34%' class='number' dominant-baseline='middle'>License #";
  string constant svgPartFive =
    "</text><text x='10%' y='40%' class='label' dominant-baseline='middle'>Hero Name</text><text x='10%' y='45%' class='base' dominant-baseline='middle'>";
  string constant svgPartSix =
    "</text><text x='10%' y='52%' class='label' dominant-baseline='middle'>Super Power</text><text x='10%' y='57%' class='base' dominant-baseline='middle'>";
  string constant svgPartSeven =
    "</text><text x='10%' y='64%' class='label' dominant-baseline='middle'>Location</text><text x='10%' y='69%' class='base' dominant-baseline='middle'>";
  string constant svgPartEight =
    "</text><path fill='#eee' d='M240 100l-40 80 100-20-40 70z'/><path fill='";
  string constant svgPartNine =
    "' d='M250 100l-40 80 100-20-40 70z'/><text x='70%' y='70%' class='number' dominant-baseline='middle' text-anchor='middle'>Issued By</text><text x='70%' y='73%' class='number' dominant-baseline='middle' text-anchor='middle'>OnChainHero Corps</text></svg>";

  // Get fancy with it! Declare a bunch of colors.
  string[] bgColors = [
    "#FFBCBC",
    "#FFE3BC",
    "#FFFFBC",
    "#C0FFBC",
    "#BCFFF9",
    "#BCCEFF",
    "#E6BCFF",
    "#FEBCFF",
    "#E1E1E1"
  ];

  string[] cardColors = [
    "#DC3434",
    "#EC8F1B",
    "#ECE21B",
    "#1FEC1B",
    "#1BECE9",
    "#1F1BEC",
    "#961BEC",
    "#DC1BEC",
    "#222222"
  ];

  // I create three arrays, each with their own theme of random words.
  // Pick some random funny words, names of anime characters, foods you like, whatever!
  string[] nouns = [
    "Man",
    "Guy",
    "Boy",
    "Girl",
    "Woman",
    "Widow",
    "Lady",
    "Person",
    "Hero",
    "Diviner",
    "Rockstar",
    "Gnome",
    "Saint",
    "Agent",
    "Spy",
    "Lion",
    "Spider",
    "Bat",
    "Aqua",
    "Octopus",
    "Cat",
    "Crow",
    "Knight",
    "Panther",
    "Queen",
    "Bolt",
    "Bird"
    "Hawks",
    "Heart",
    "Light",
    "Patriot",
    "Phantom",
    "Blade",
    "Shield",
    "Storm",
    "Tiger",
    "Voodoo",
    "Bee",
    "America",
    "Britain",
    "Cross",
    "Universe",
    "Avenger",
    "Crusader",
    "Dynamo",
    "King",
    "Beast",
    "Phoenix",
    "Strange",
    "Lord",
    "Frost",
    "of Doom",
    "Machine",
    "Rider",
    "Warrior",
    "Witch"
  ];

  string[] prefixes = [
    "Mr.",
    "Sir",
    "President",
    "The",
    "Mrs.",
    "Ms.",
    "Doctor",
    "Agent",
    "Captain",
    "Iron",
    "Baron",
    "Black",
    "Big",
    "Invisible",
    "Turbo",
    "Green",
    "Amazon",
    "Ant",
    "Wonder",
    "God",
    "Crimson",
    "Death",
    "Dream",
    "Echo",
    "Dyna",
    "Fire",
    "Ice",
    "War",
    "Fury",
    "Ghost",
    "Lava",
    "Little",
    "Lightning",
    "Madame",
    "Omega",
    "Psycho",
    "Shadow",
    "Thunder",
    "Scarlett",
    "X",
    "Zombie"
  ];

  string[] powers = [
    "Ability Shift",
    "Absorption",
    "Accuracy",
    "Adaptation",
    "Aerokinesis",
    "Agility",
    "Animal Attributes",
    "Animal Control",
    "Animal Oriented Powers",
    "Animation",
    "Anti-Gravity",
    "Apotheosis",
    "Astral Projection",
    "Astral Trap",
    "Astral Travel",
    "Atmokinesis",
    "Audiokinesis",
    "Banish",
    "Biokinesis",
    "Bullet Time",
    "Camouflage",
    "Changing Armor",
    "Chlorokinesis",
    "Chronokinesis",
    "Clairvoyance",
    "Cloaking",
    "Cold Resistance",
    "Cross-Dimensional Awareness",
    "Cross-Dimensional Travel",
    "Cryokinesis",
    "Danger Sense",
    "Darkforce Manipulation",
    "Death Touch",
    "Density Control",
    "Dexterity",
    "Duplication",
    "Durability",
    "Echokinesis",
    "Elasticity",
    "Electrical Transport",
    "Electrokinesis",
    "Elemental Transmogrification",
    "EmpathyEndurance",
    "Energy Absorption",
    "Energy Armor",
    "Energy Beams",
    "Energy Blasts",
    "Energy Constructs",
    "Energy Manipulation",
    "Energy Resistance",
    "Enhanced Hearing",
    "Enhanced Memory",
    "Enhanced Senses",
    "Enhanced Smell",
    "Enhanced Touch",
    "Entropy Projection",
    "Fire Resistance",
    "Flight",
    "Force Fields",
    "Geokinesis",
    "Gliding",
    "Gravitokinesis",
    "Grim Reaping",
    "Healing Factor",
    "Heat Generation",
    "Heat Resistance",
    "Human physical perfection",
    "Hydrokinesis",
    "Hyperkinesis",
    "Hypnokinesis",
    "Illumination",
    "Illusions",
    "Immortality",
    "Insanity",
    "Intangibility",
    "Intelligence",
    "Intuitive aptitude",
    "Invisibility",
    "Invulnerability",
    "Jump",
    "Lantern Power Ring",
    "Latent Abilities",
    "Levitation",
    "Longevity",
    "Magic",
    "Magic Resistance",
    "Magnetokinesis",
    "Matter Absorption",
    "MeltingMind Blast",
    "Mind Control",
    "Mind Control Resistance",
    "Molecular Combustion",
    "Molecular Dissipation",
    "Molecular Immobilization",
    "Molecular Manipulation",
    "Natural Armor",
    "Natural Weapons",
    "Nova Force",
    "Omnilingualism",
    "Omnipotence",
    "OmnitrixOrbing",
    "Phasing",
    "Photographic Reflexes",
    "Photokinesis",
    "Physical Anomaly",
    "Portal Creation",
    "Possession",
    "Power Absorption",
    "Power Augmentation",
    "Power Cosmic",
    "Power Nullifier",
    "Power Sense",
    "Power Suit",
    "Precognition",
    "Probability Manipulation",
    "Projection",
    "Psionic Powers",
    "Psychokinesis",
    "Pyrokinesis",
    "Qwardian Power Ring",
    "Radar Sense",
    "Radiation Absorption",
    "Radiation Control",
    "Radiation Immunity",
    "Reality Warping",
    "Reflexes",
    "Regeneration",
    "Resurrection",
    "Seismic Power",
    "Self-Sustenance",
    "Separation",
    "Shapeshifting",
    "Size Changing",
    "SonarSonic Scream",
    "Spatial Awareness",
    "Stamina",
    "Stealth",
    "Sub-Mariner",
    "Substance Secretion",
    "Summoning",
    "Super Breath",
    "Super Speed",
    "Super Strength",
    "Symbiote Costume",
    "Technopath/Cyberpath",
    "Telekinesis",
    "Telepathy",
    "Telepathy Resistance",
    "Teleportation",
    "Terrakinesis",
    "Thermokinesis",
    "Thirstokinesis",
    "Time Travel",
    "Timeframe Control",
    "Toxikinesis",
    "Toxin and Disease Resistance",
    "Umbrakinesis",
    "Underwater breathing",
    "Vaporising Beams",
    "Vision - Cryo",
    "Vision - Heat",
    "Vision - Infrared",
    "Vision - Microscopic",
    "Vision - Night",
    "Vision - Telescopic",
    "Vision - Thermal",
    "Vision - X-Ray",
    "Vitakinesis",
    "Wallcrawling",
    "Weapon-based Powers",
    "Weapons Master",
    "Web Creation",
    "Wishing"
  ];

  // based on top 20 most visited cities in the world
  string[] locations = [
    "Tokyo, Japan",
    "Bangkok, Thailand",
    "Paris, France",
    "London, United Kingdom",
    "Dubai, United Arab Emirates",
    "Kuala Lumpur, Malaysia",
    "New York, United States",
    "Istanbul, Turkey",
    "Seoul, Korea",
    "Osaka, Japan",
    "Phuket, Thailand",
    "Milan, Italy",
    "Barcelona, Spain",
    "San Francisco, United States",
    "Los Angeles, United States"
  ];

  // distribution here is:
  // - A+ - 1/10
  // - A - 2/10
  // - B - 5/10
  // - C - 2/10
  // Idea is to make A++ and A a bit more rare while keeping B to normal
  // distribution since no one would want to get a C.
  string[] grades = [
    "A+",
    "A",
    "A",
    "B",
    "B",
    "B",
    "B",
    "B",
    "B",
    "C",
    "C"
  ];
}

