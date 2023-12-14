/// Data model for the on boarding UI element
class OnBoardingItemData {
  OnBoardingItemData({
    required this.title,
    required this.description,
    required this.imagePath,
  });

  final String title;
  final String description;
  final String imagePath;
}

const rootPath = 'assets/images/onboarding';

final onBoardingData = [
  OnBoardingItemData(
    title: 'Find Hundreds of Hotels',
    description:
        'Discover hundreds of hotels that spread across the world for you',
    imagePath: '$rootPath/ob1.png',
  ),
  OnBoardingItemData(
    title: 'Make a Destination Plan',
    description:
        'Choose the location and we have many hotel recommendations wherever you are',
    imagePath: '$rootPath/ob2.png',
  ),
  OnBoardingItemData(
    title: 'Let’s Discover the World',
    description:
        'Book your hotel right now for the next level travel.\nEnjoy your trip!',
    imagePath: '$rootPath/ob3.png',
  ),
];
