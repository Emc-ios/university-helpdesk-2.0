// FAQ Data for University Helpdesk
// This data will be used to feed the AI chatbot

class FaqData {
  static List<Map<String, dynamic>> getDefaultFaqs() {
    return [
      // Enrollment & Grades Category
      {
        'question': 'When is the enrollment period for the next semester?',
        'answer':
            'Enrollment for the First Semester begins on August 5th and ends on August 20th. Late enrollment is allowed until August 25th with a penalty fee.',
        'keywords': [
          'enrollment',
          'semester',
          'registration',
          'enroll',
          'period',
        ],
        'category': 'Enrollment & Grades',
      },
      {
        'question': 'How do I view my grades?',
        'answer':
            'You can view your grades by logging into the Student Portal at portal.university.edu using your Student ID. Click on "My Records" and then "Grades."',
        'keywords': ['grades', 'view', 'portal', 'records', 'transcript'],
        'category': 'Enrollment & Grades',
      },
      {
        'question': 'What are the requirements for incoming freshmen?',
        'answer':
            'Freshmen must submit their Form 138 (High School Card), Certificate of Good Moral Character, PSA Birth Certificate, and 2 recent 2x2 ID photos.',
        'keywords': [
          'freshmen',
          'requirements',
          'documents',
          'admission',
          'new student',
          'enrollment requirements',
        ],
        'category': 'Enrollment & Grades',
      },
      // Scholarships Category
      {
        'question': 'How can I apply for an academic scholarship?',
        'answer':
            'Students with a GWA of 1.75 or better with no grade lower than 2.5 are eligible. Apply at the Office of Student Affairs (OSA) before the semester starts.',
        'keywords': [
          'scholarship',
          'academic',
          'apply',
          'GWA',
          'financial aid',
          'OSA',
        ],
        'category': 'Scholarships',
      },
      {
        'question': 'Do you offer athletic scholarships?',
        'answer':
            'Yes, varsity players are entitled to a 50% to 100% tuition discount depending on their team status. Visit the Sports Development Office at the Gym for tryouts.',
        'keywords': [
          'athletic',
          'sports',
          'varsity',
          'scholarship',
          'tryouts',
          'gym',
        ],
        'category': 'Scholarships',
      },
      // Offices & Facilities Category
      {
        'question': 'Where is the Registrar\'s Office located?',
        'answer':
            'The Registrar\'s Office is located on the Ground Floor of the Main Building, Room 101, right next to the Accounting Office.',
        'keywords': [
          'registrar',
          'office',
          'location',
          'main building',
          'room 101',
        ],
        'category': 'Offices & Facilities',
      },
      {
        'question': 'What are the library operating hours?',
        'answer':
            'The University Library is open Monday to Friday from 7:00 AM to 6:00 PM, and Saturdays from 8:00 AM to 12:00 PM.',
        'keywords': [
          'library',
          'hours',
          'operating hours',
          'schedule',
          'open',
          'closed',
        ],
        'category': 'Offices & Facilities',
      },
      {
        'question': 'Where can I get a medical clearance?',
        'answer':
            'Medical clearances are issued at the University Clinic, located near the South Gate entrance.',
        'keywords': [
          'medical',
          'clearance',
          'clinic',
          'health',
          'south gate',
          'medical certificate',
        ],
        'category': 'Offices & Facilities',
      },
      // Personnel & Organizations Category
      {
        'question': 'Who is the Dean of the College of Computer Studies?',
        'answer':
            'The current Dean is Dr. Ada Lovelace. Her office is located on the 3rd floor of the IT Building.',
        'keywords': [
          'dean',
          'computer studies',
          'IT',
          'CCS',
          'Dr. Ada Lovelace',
          'faculty',
        ],
        'category': 'Personnel & Organizations',
      },
      {
        'question': 'How do I join the Student Council?',
        'answer':
            'Elections for the Student Council are held every April. You can also volunteer for committees by visiting the Student Council office in the Student Center.',
        'keywords': [
          'student council',
          'join',
          'elections',
          'volunteer',
          'student center',
          'organizations',
        ],
        'category': 'Personnel & Organizations',
      },
    ];
  }
}
