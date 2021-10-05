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

  // Same old stuff, pick a random color.
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

  // Same old stuff, pick a random color.
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

  // Same old stuff, pick a random color.
  function pickRandomFirstName(uint256 tokenId)
    public
    view
    returns (string memory)
  {
    uint256 rand = random(
      string(abi.encodePacked("FIRST_NAME", Strings.toString(tokenId)))
    );
    rand = rand % firstNames.length;
    return firstNames[rand];
  }

  // Same old stuff, pick a random color.
  function pickRandomLastName(uint256 tokenId)
    public
    view
    returns (string memory)
  {
    uint256 rand = random(
      string(abi.encodePacked("LAST_NAME", Strings.toString(tokenId)))
    );
    rand = rand % lastNames.length;
    return lastNames[rand];
  }

  function random(string memory input) internal pure returns (uint256) {
    return uint256(keccak256(abi.encodePacked(input)));
  }

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
      abi.encodePacked(cardColor, svgPartThree, _uint2str(newItemId))
    );
    string memory finalSvgThree = string(
      abi.encodePacked(svgPartFour, heroName, svgPartFive)
    );
    string memory finalSvgFour = string(
      abi.encodePacked(
        pickRandomPower(newItemId),
        svgPartSix,
        string(
          abi.encodePacked(
            pickRandomFirstName(newItemId),
            " ",
            pickRandomLastName(newItemId)
          )
        )
      )
    );
    string memory finalSvgFive = string(
      abi.encodePacked(svgPartSeven, cardColor, svgPartEight)
    );

    string memory finalSvg = string(
      abi.encodePacked(
        finalSvgOne,
        finalSvgTwo,
        finalSvgThree,
        finalSvgFour,
        finalSvgFive
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

  // This is our SVG code. All we need to change is the word that's displayed. Everything else stays the same.
  // So, we make a baseSvg variable here that all our NFTs can use.
  // We split the SVG at the part where it asks for the background color.
  string constant svgPartOne =
    "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base,.label,.number{fill:#777;font-family:Monaco,sans-serif;font-size:8px}.base,.label{font-size:10px}.base{fill:#222;font-size:12px;font-weight:600}</style><rect width='100%' height='100%' fill='";
  string constant svgPartTwo = "'/><rect width='90%' height='60%' fill='";
  string constant svgPartThree =
    "' x='5%' y='20%' rx='20' style='-webkit-filter:drop-shadow(0 0 10px rgba(0,0,0,.5))' filter='drop-shadow(0 0 10px rgba(0,0,0,.5))'/><rect width='88%' height='58%' fill='#fff' x='6%' y='21%' rx='18'/><text x='10%' y='30%' class='base' dominant-baseline='middle'>Super Hero License</text><text x='10%' y='34%' class='number' dominant-baseline='middle'>License #";
  string constant svgPartFour =
    "</text><text x='10%' y='40%' class='label' dominant-baseline='middle'>Hero Name</text><text x='10%' y='45%' class='base' dominant-baseline='middle'>";
  string constant svgPartFive =
    "</text><text x='10%' y='52%' class='label' dominant-baseline='middle'>Super Power</text><text x='10%' y='57%' class='base' dominant-baseline='middle'>";
  string constant svgPartSix =
    "</text><text x='10%' y='64%' class='label' dominant-baseline='middle'>Civilian Name</text><text x='10%' y='69%' class='base' dominant-baseline='middle'>";
  string constant svgPartSeven =
    "</text><path fill='#eee' d='M240 100l-40 80 100-20-40 70z'/><path fill='";
  string constant svgPartEight =
    "' d='M250 100l-40 80 100-20-40 70z'/><text x='70%' y='67%' class='number' dominant-baseline='middle' text-anchor='middle'>Issued By</text><text x='70%' y='70%' class='number' dominant-baseline='middle' text-anchor='middle'>OnChainHero Corps</text></svg>";

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
  string[] firstNames = [
    "Olivia",
    "Liam",
    "Emma",
    "Noah",
    "Amelia",
    "Oliver",
    "Ava",
    "Elijah",
    "Sophia",
    "Lucas",
    "Charlotte",
    "Mason",
    "Isabella",
    "Levi",
    "Mia",
    "Asher",
    "Luna",
    "James",
    "Harper",
    "Mateo",
    "Gianna",
    "Leo",
    "Evelyn",
    "Ethan",
    "Aria",
    "Benjamin",
    "Ella",
    "Logan",
    "Ellie",
    "Aiden",
    "Mila",
    "Jack",
    "Layla",
    "Grayson",
    "Ryilee",
    "Leriel",
    "Camila",
    "Jackson",
    "Avery",
    "Wyatt",
    "Lily",
    "Henry",
    "Scarlett",
    "Carter",
    "Sofia",
    "Sebastian",
    "Nova",
    "William",
    "Aurora",
    "Daniel",
    "Chloe",
    "Owen",
    "Riley",
    "Julian",
    "Abigail",
    "Alexander",
    "Hazel",
    "Michael",
    "Nora",
    "Hudson",
    "Zoey",
    "Ezra",
    "Isla",
    "Muhammad",
    "Elena",
    "Luke",
    "Penelope",
    "Jacob",
    "Eleanor",
    "Lincoln",
    "Elizabeth",
    "Samuel",
    "Madison",
    "Gabriel",
    "Emilia",
    "Jayden",
    "Willow",
    "Josiah",
    "Emily",
    "Maverick",
    "Eliana",
    "David",
    "Violet",
    "Luca",
    "Stella",
    "Elias",
    "Paisley",
    "Jaxon",
    "Maya",
    "Kai",
    "Addison",
    "Eli",
    "Everly",
    "John",
    "Grace",
    "Isaiah",
    "Ivy",
    "Anthony",
    "Litte",
    "Matthew"
  ];
  string[] lastNames = [
    "Smith",
    "Johnson",
    "Williams",
    "Brown",
    "Jones",
    "Miller",
    "Davis",
    "Garcia",
    "Rodriguez",
    "Wilson",
    "Martinez",
    "Anderson",
    "Taylor",
    "Thomas",
    "Hernandez",
    "Moore",
    "Martin",
    "Jackson",
    "Thompson",
    "White",
    "Lopez",
    "Lee",
    "Gonzalez",
    "Harris",
    "Clark",
    "Lewis",
    "Robinson",
    "Walker",
    "Perez",
    "Hall",
    "Young",
    "Allen",
    "Sanchez",
    "Wright",
    "King",
    "Scott",
    "Green",
    "Baker",
    "Adams",
    "Nelson",
    "Hill",
    "Ramirez",
    "Campbell",
    "Mitchell",
    "Roberts",
    "Carter",
    "Phillips",
    "Evans",
    "Turner",
    "Torres",
    "Parker",
    "Collins",
    "Edwards",
    "Stewart",
    "Flores",
    "Morris",
    "Nguyen",
    "Murphy",
    "Rivera",
    "Cook",
    "Rogers",
    "Morgan",
    "Peterson",
    "Cooper",
    "Reed",
    "Bailey",
    "Bell",
    "Gomez",
    "Kelly",
    "Howard",
    "Ward",
    "Cox",
    "Diaz",
    "Richardson",
    "Wood",
    "Watson",
    "Brooks",
    "Bennett",
    "Gray",
    "James",
    "Reyes",
    "Cruz",
    "Hughes",
    "Price",
    "Myers",
    "Long",
    "Foster",
    "Sanders",
    "Ross",
    "Morales",
    "Powell",
    "Sullivan",
    "Russell",
    "Ortiz",
    "Jenkins",
    "Gutierrez",
    "Perry",
    "Butler",
    "Barnes",
    "Fisher",
    "Henderson",
    "Coleman",
    "Simmons",
    "Patterson",
    "Jordan",
    "Reynolds",
    "Hamilton",
    "Graham",
    "Kim",
    "Gonzales",
    "Alexander",
    "Ramos",
    "Wallace",
    "Griffin",
    "West",
    "Cole",
    "Hayes",
    "Chavez",
    "Gibson",
    "Bryant",
    "Ellis",
    "Stevens",
    "Murray",
    "Ford",
    "Marshall",
    "Owens",
    "Mcdonald",
    "Harrison",
    "Ruiz",
    "Kennedy",
    "Wells",
    "Alvarez",
    "Woods",
    "Mendoza",
    "Castillo",
    "Olson",
    "Webb",
    "Washington",
    "Tucker",
    "Freeman",
    "Burns",
    "Henry",
    "Vasquez",
    "Snyder",
    "Simpson",
    "Crawford",
    "Jimenez",
    "Porter",
    "Mason",
    "Shaw",
    "Gordon",
    "Wagner",
    "Hunter",
    "Romero",
    "Hicks",
    "Dixon",
    "Hunt",
    "Palmer",
    "Robertson",
    "Black",
    "Holmes",
    "Stone",
    "Meyer",
    "Boyd",
    "Mills",
    "Warren",
    "Fox",
    "Rose",
    "Rice",
    "Moreno",
    "Schmidt",
    "Patel",
    "Ferguson",
    "Nichols",
    "Herrera",
    "Medina",
    "Ryan",
    "Fernandez",
    "Weaver",
    "Daniels",
    "Stephens",
    "Gardner",
    "Payne",
    "Kelley",
    "Dunn",
    "Pierce",
    "Arnold",
    "Tran",
    "Spencer",
    "Peters",
    "Hawkins",
    "Grant",
    "Hansen",
    "Castro",
    "Hoffman",
    "Hart",
    "Elliott",
    "Cunningham",
    "Knight",
    "Bradley",
    "Carroll",
    "Hudson",
    "Duncan",
    "Armstrong",
    "Berry",
    "Andrews",
    "Johnston",
    "Ray",
    "Lane",
    "Riley",
    "Carpenter",
    "Perkins",
    "Aguilar",
    "Silva",
    "Richards",
    "Willis",
    "Matthews",
    "Chapman",
    "Lawrence",
    "Garza",
    "Vargas",
    "Watkins",
    "Wheeler",
    "Larson",
    "Carlson",
    "Harper",
    "George",
    "Greene",
    "Burke",
    "Guzman",
    "Morrison",
    "Munoz",
    "Jacobs",
    "Obrien",
    "Lawson",
    "Franklin",
    "Lynch",
    "Bishop",
    "Carr",
    "Salazar",
    "Austin",
    "Mendez",
    "Gilbert",
    "Jensen",
    "Williamson",
    "Montgomery",
    "Harvey",
    "Oliver",
    "Howell",
    "Dean",
    "Hanson",
    "Weber",
    "Garrett",
    "Sims",
    "Burton",
    "Fuller",
    "Soto",
    "Mccoy",
    "Welch",
    "Chen",
    "Schultz",
    "Walters",
    "Reid",
    "Fields",
    "Walsh",
    "Little",
    "Fowler",
    "Bowman",
    "Davidson",
    "May",
    "Day",
    "Schneider",
    "Newman",
    "Brewer",
    "Lucas",
    "Holland",
    "Wong",
    "Banks",
    "Santos",
    "Curtis",
    "Pearson",
    "Delgado",
    "Valdez",
    "Pena",
    "Rios",
    "Douglas",
    "Sandoval",
    "Barrett",
    "Hopkins",
    "Keller",
    "Guerrero",
    "Stanley",
    "Bates",
    "Alvarado",
    "Beck",
    "Ortega",
    "Wade",
    "Estrada",
    "Contreras",
    "Barnett",
    "Caldwell",
    "Santiago",
    "Lambert"
  ];
}
