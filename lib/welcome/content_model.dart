class UnbordingContent {
  String image;
  String title;
  String discription;

  UnbordingContent(
      {required this.image, required this.title, required this.discription});
}

List<UnbordingContent> contents = [
  UnbordingContent(
      title: 'Chat any time, anywhere',
      image: 'assets/images/1.png',
      discription:
          "Passing of any information on any screen, any device instantly"),
  UnbordingContent(
      title: 'Your space is your dream',
      image: 'assets/images/2.png',
      discription:
          "A lag-free video chat connection your users is easy and much everywhere on every device"),
  UnbordingContent(
      title: 'Perfect chat solution',
      image: 'assets/images/3.png',
      discription: "Your space in your dream for every time"),
];
