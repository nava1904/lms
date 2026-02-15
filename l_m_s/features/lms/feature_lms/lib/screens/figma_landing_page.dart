import 'package:flutter/material.dart';

class FigmaLandingPage extends StatefulWidget {
  const FigmaLandingPage({super.key});

  @override
  State<FigmaLandingPage> createState() => _FigmaLandingPageState();
}

class _FigmaLandingPageState extends State<FigmaLandingPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Navigation Bar
            _buildNavigationBar(theme, isMobile),
            
            // Hero Section
            _buildHeroSection(theme, isMobile),
            
            // Key Features Section
            _buildFeaturesSection(theme, isMobile),
            
            // Why Choose Us Section
            _buildWhyChooseSection(theme, isMobile),
            
            // Testimonials Section
            _buildTestimonialsSection(theme, isMobile),
            
            // Courses Section
            _buildCoursesSection(theme, isMobile),
            
            // Pricing Section
            _buildPricingSection(theme, isMobile),
            
            // FAQ Section
            _buildFAQSection(theme, isMobile),
            
            // CTA Section
            _buildCTASection(theme, isMobile),
            
            // Footer
            _buildFooter(theme, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBar(ThemeData theme, bool isMobile) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Text(
            'EduLearn',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A73E8),
            ),
          ),
          // Nav Items
          if (!isMobile)
            Row(
              children: ['Features', 'Courses', 'Pricing', 'Contact'].map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Navigate to $item')),
                      );
                    },
                    child: Text(
                      item,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          // Auth Buttons
          Row(
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/enhanced-login'),
                child: const Text('Login'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(ThemeData theme, bool isMobile) {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 60,
        vertical: isMobile ? 40 : 80,
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroContent(theme),
                const SizedBox(height: 32),
                _buildHeroImage(),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildHeroContent(theme)),
                const SizedBox(width: 40),
                Expanded(child: _buildHeroImage()),
              ],
            ),
    );
  }

  Widget _buildHeroContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learn Anything, Anytime, Anywhere',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Master new skills with our expert instructors. Choose from thousands of courses across all categories.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/enhanced-login'),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Learning'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Demo video will play here')),
                );
              },
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Watch Demo'),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            _buildStatBadge('50K+', 'Active Learners'),
            const SizedBox(width: 32),
            _buildStatBadge('1000+', 'Courses'),
            const SizedBox(width: 32),
            _buildStatBadge('500+', 'Instructors'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatBadge(String number, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A73E8),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        'https://images.unsplash.com/photo-1633356122544-f134324ef6db?w=600&h=500&fit=crop',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildFeaturesSection(ThemeData theme, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 60,
        vertical: 80,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why Our Platform Stands Out',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 40),
          GridView.count(
            crossAxisCount: isMobile ? 1 : 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            children: [
              _buildFeatureCard(theme, '📚', 'Diverse Courses', 'From beginner to expert level courses'),
              _buildFeatureCard(theme, '👨‍🏫', 'Expert Instructors', 'Learn from industry professionals'),
              _buildFeatureCard(theme, '📱', 'Learn on Any Device', 'Mobile, tablet, or desktop access'),
              _buildFeatureCard(theme, '🏆', 'Certificates', 'Earn recognized certificates'),
              _buildFeatureCard(theme, '🔄', 'Lifetime Access', 'Lifetime access to course materials'),
              _buildFeatureCard(theme, '💬', '24/7 Support', 'Get help when you need it'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(ThemeData theme, String emoji, String title, String description) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhyChooseSection(ThemeData theme, bool isMobile) {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 60,
        vertical: 80,
      ),
      child: isMobile
          ? Column(
              children: [
                _buildWhyChooseContent(theme),
                const SizedBox(height: 32),
                _buildWhyChooseImage(),
              ],
            )
          : Row(
              children: [
                Expanded(child: _buildWhyChooseImage()),
                const SizedBox(width: 60),
                Expanded(child: _buildWhyChooseContent(theme)),
              ],
            ),
    );
  }

  Widget _buildWhyChooseContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personalized Learning Experience',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 20),
        _buildBulletPoint(theme, 'Adaptive learning paths tailored to your pace'),
        _buildBulletPoint(theme, 'Real-world projects and practical exercises'),
        _buildBulletPoint(theme, 'Interactive quizzes and assessments'),
        _buildBulletPoint(theme, 'Community support and peer learning'),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/enhanced-login'),
          child: const Text('Learn More'),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyChooseImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        'https://images.unsplash.com/photo-1552664730-d307ca884978?w=500&h=500&fit=crop',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildTestimonialsSection(ThemeData theme, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 60,
        vertical: 80,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What Students Say',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 40),
          GridView.count(
            crossAxisCount: isMobile ? 1 : 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            children: [
              _buildTestimonialCard(
                theme,
                'Arjun Kumar',
                'Cleared JEE Advanced with flying colors! The courses are comprehensive and well-structured.',
                '⭐⭐⭐⭐⭐',
              ),
              _buildTestimonialCard(
                theme,
                'Priya Singh',
                'Best online learning platform. The instructors are amazing and support is always there.',
                '⭐⭐⭐⭐⭐',
              ),
              _buildTestimonialCard(
                theme,
                'Rahul Patel',
                'Flexible learning schedule, excellent content, and affordable pricing. Highly recommended!',
                '⭐⭐⭐⭐⭐',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(ThemeData theme, String name, String text, String stars) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(stars, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesSection(ThemeData theme, bool isMobile) {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 60,
        vertical: 80,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Courses',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All Courses →'),
              ),
            ],
          ),
          const SizedBox(height: 40),
          GridView.count(
            crossAxisCount: isMobile ? 1 : 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildCourseCard(theme, 'Physics', '12 lessons', '₹2,999', Colors.blue),
              _buildCourseCard(theme, 'Chemistry', '14 lessons', '₹3,499', Colors.green),
              _buildCourseCard(theme, 'Biology', '16 lessons', '₹2,799', Colors.orange),
              _buildCourseCard(theme, 'Mathematics', '18 lessons', '₹2,499', Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(ThemeData theme, String name, String lessons, String price, Color color) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.book, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              lessons,
              style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  price,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A73E8),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                  child: const Text('Enroll'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSection(ThemeData theme, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 60,
        vertical: 80,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Simple & Transparent Pricing',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 40),
          GridView.count(
            crossAxisCount: isMobile ? 1 : 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            children: [
              _buildPricingCard(theme, 'Basic', '₹0/month', ['Access to sample courses', 'Community support'], false),
              _buildPricingCard(theme, 'Pro', '₹299/month', ['All Basic features', 'All premium courses', 'Priority support'], true),
              _buildPricingCard(theme, 'Enterprise', 'Contact Us', ['Custom training', 'Dedicated support', 'Group licensing'], false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(ThemeData theme, String plan, String price, List<String> features, bool highlighted) {
    return Card(
      elevation: highlighted ? 4 : 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: highlighted ? const Color(0xFF1A73E8) : Colors.grey[200]!,
          width: highlighted ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (highlighted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A73E8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'POPULAR',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF1A73E8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text(
              plan,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A73E8),
              ),
            ),
            const SizedBox(height: 20),
            ...features.map((feature) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(Icons.check, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      feature,
                      style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[700]),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/enhanced-login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: highlighted ? const Color(0xFF1A73E8) : Colors.grey[200],
                  foregroundColor: highlighted ? Colors.white : Colors.black,
                ),
                child: const Text('Get Started'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection(ThemeData theme, bool isMobile) {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 60,
        vertical: 80,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frequently Asked Questions',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 40),
          _buildFAQItem(theme, 'How do I get started?', 'Sign up, choose a course, and start learning immediately!'),
          _buildFAQItem(theme, 'Do I get a certificate?', 'Yes, certificates are issued after completing a course.'),
          _buildFAQItem(theme, 'Can I access courses offline?', 'Yes, download courses and access them offline.'),
          _buildFAQItem(theme, 'What if I need help?', '24/7 support team ready to assist you.'),
        ],
      ),
    );
  }

  Widget _buildFAQItem(ThemeData theme, String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection(ThemeData theme, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A73E8).withOpacity(0.9),
            const Color(0xFF8B5CF6).withOpacity(0.9),
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 60,
        vertical: 60,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Ready to Transform Your Skills?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Join thousands of learners and start your journey today',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/enhanced-login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1A73E8),
            ),
            child: const Text('Start Free Trial'),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(ThemeData theme, bool isMobile) {
    return Container(
      color: Colors.grey[900],
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 60,
        vertical: 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFooterColumn(theme, 'Product', ['Courses', 'Pricing', 'About']),
                _buildFooterColumn(theme, 'Company', ['Blog', 'Careers', 'Contact']),
                _buildFooterColumn(theme, 'Legal', ['Privacy', 'Terms', 'Cookie']),
                _buildFooterColumn(theme, 'Social', ['Twitter', 'Facebook', 'LinkedIn']),
              ],
            ),
          const SizedBox(height: 32),
          Divider(color: Colors.grey[700]),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('© 2024 EduLearn. All rights reserved.', style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[400])),
              Row(
                children: [
                  Text('Made with ❤️ by EduLearn Team', style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[400])),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterColumn(ThemeData theme, String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              item,
              style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[400]),
            ),
          );
        }),
      ],
    );
  }
}
