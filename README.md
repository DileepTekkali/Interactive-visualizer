# study_viz

An interactive web application for visualizing mathematical and scientific concepts through dynamic simulations, calculators, and educational tools. Designed for students from Class 6 to 12.

![Flutter](https://img.shields.io/badge/Flutter-3.27.0-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.7.0-0175C2?style=for-the-badge&logo=dart)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

## Live Demo

**https://study-viz.vercel.app**

## Features

### Mathematics

#### Class 6-8 (Middle School)
- **Basic Geometry** - Circles, triangles, polygons, shape properties
- **Data Handling** - Charts and data representation
- **Number Line** - Positive and negative numbers, inequalities
- **Mensuration 3D** - Volume and surface area calculations

#### Class 9-10 (High School)
- **Linear Equations** - Graph linear functions with slope-intercept form
- **Quadratic Graphs** - Visualize parabolas and analyze roots
- **Trigonometry Ratios** - Interactive unit circle, Sin, Cos, Tan functions
- **Statistics** - Mean, median, mode, data distributions
- **Coordinate Geometry** - Distance, midpoint, and section formulas
- **Arithmetic Progressions** - Sequences and series
- **Circles & Tangents** - Circle properties and tangent calculations

#### Class 11-12 (Senior Secondary)
- **Calculus** - Limits, derivatives, and rate of change
- **Vectors (2D)** - Vector addition and resultant calculations
- **Conic Sections** - Parabola, ellipse, and hyperbola
- **Complex Numbers** - Real and imaginary operations
- **Linear Programming** - Optimize objective functions graphically

### Physics

#### Mechanics
- **Newton's Laws** - F = ma calculations with visual animations
- **Friction Simulator** - Inclined plane with normal force, friction force
- **Lever Machine** - Mechanical advantage calculations

#### Energy & Motion
- **Motion Graphs** - Position, velocity, and acceleration over time
- **Energy Simulator** - Kinetic and potential energy conservation
- **Wave Simulator** - Wave properties and interference

#### Electricity & Magnetism
- **Circuit Simulator** - Series and parallel circuits with Ohm's Law
- **Magnetic Field** - Field lines and magnetic poles visualization

#### Optics & Waves
- **Snell's Law** - Light refraction through different mediums
- **Heat Transfer** - Conduction, convection, and radiation

### Chemistry

#### Atomic Structure
- **Atom Builder** - Build atoms with protons, neutrons, and electrons
- **Periodic Table** - Full element explorer with all properties

#### Chemical Bonding
- **Bonding Simulator** - Ionic, covalent, and metallic bonds with animations

#### Chemical Processes
- **Separation Process** - Filtration, evaporation, distillation, magnetic separation
- **Mole Calculator** - Convert between mass, moles, and particles

#### Reaction Chemistry
- **Le Chatelier Principle** - Equilibrium shifts with temperature changes
- **Reaction Kinetics** - Rate of reactions and concentration graphs
- **Thermodynamics** - Energy profile diagrams for exo/endothermic reactions
- **Change Detector** - Physical vs chemical change classifier

## Tech Stack

### Frontend
- **Flutter 3.27.0** - UI framework
- **Dart 3.7.0** - Programming language
- **fl_chart** - Interactive charts and graphs
- **google_fonts** - Custom typography

### Backend (Optional)
- **Python 3.11** - API server
- **FastAPI** - REST API framework

> **Note:** All calculations are now performed locally on the frontend. Backend is optional.

## Getting Started

### Prerequisites
- Flutter SDK 3.27.0 or higher
- Git

### Frontend Setup

```bash
# Clone the repository
git clone https://github.com/DileepTekkali/study_viz.git
cd study_viz/frontend

# Install dependencies
flutter pub get

# Run the app
flutter run

# Or run in Chrome specifically
flutter run -d chrome
```

### Build for Web

```bash
cd frontend

# Build for production
flutter build web

# The build output will be in frontend/build/web/
```

### Local Server for Web Build

```bash
cd frontend/build/web

# Using Python
python3 -m http.server 8080

# Or using Node.js
npx serve .

# Or using PHP
php -S localhost:8080
```

## Deployment to Vercel

### Option 1: GitHub Integration (Recommended)

1. Push your code to GitHub
2. Go to [vercel.com/new](https://vercel.com/new)
3. Import your GitHub repository
4. Configure:
   - **Framework Preset**: Others
   - **Root Directory**: `.` or leave as `/`
   - **Build Command**: `flutter build web` (or `cd frontend && flutter build web`)
   - **Output Directory**: `frontend/build/web`
   - **Install Command**: `flutter pub get`
5. Click "Deploy"

### Option 2: CLI Deployment

```bash
# Install Vercel CLI
npm install -g vercel

# Login
vercel login

# Deploy
cd frontend
vercel --prod
```

### Option 3: Pre-built Files

1. Build locally: `flutter build web`
2. Upload `frontend/build/web` folder contents to Vercel or any static hosting

## Project Structure

```
study_viz/
├── frontend/
│   ├── lib/
│   │   ├── core/
│   │   │   ├── theme/          # App theme and colors
│   │   │   └── constants.dart   # Routes and constants
│   │   ├── features/
│   │   │   ├── calculus/        # Calculus visualizations
│   │   │   ├── chemistry/       # Chemistry simulations
│   │   │   │   ├── atom_builder_screen.dart
│   │   │   │   ├── periodic_table_screen.dart
│   │   │   │   ├── bonding_screen.dart
│   │   │   │   ├── separation_screen.dart
│   │   │   │   ├── equilibrium_screen.dart
│   │   │   │   ├── thermodynamics_screen.dart
│   │   │   │   ├── kinetics_screen.dart
│   │   │   │   ├── mole_calculator_screen.dart
│   │   │   │   └── change_detector_screen.dart
│   │   │   ├── physics/         # Physics simulations
│   │   │   │   ├── circuit_simulator_screen.dart
│   │   │   │   ├── friction_screen.dart
│   │   │   │   ├── lever_machine_screen.dart
│   │   │   │   ├── newtons_laws_screen.dart
│   │   │   │   ├── motion_graph_screen.dart
│   │   │   │   ├── optics_screen.dart
│   │   │   │   ├── energy_simulator_screen.dart
│   │   │   │   ├── wave_simulator_screen.dart
│   │   │   │   ├── heat_transfer_screen.dart
│   │   │   │   └── magnetic_field_screen.dart
│   │   │   ├── geometry/
│   │   │   ├── trigonometry/
│   │   │   ├── vectors/
│   │   │   └── ...              # Other math modules
│   │   └── shared/
│   │       ├── widgets/          # Reusable widgets
│   │       │   ├── main_layout.dart
│   │       │   ├── app_sidebar.dart
│   │       │   └── parameter_slider.dart
│   │       ├── services/        # Local services
│   │       │   └── chemistry_service_local.dart
│   │       └── painters/        # Custom painters
│   └── pubspec.yaml
├── backend/                      # Optional backend
│   ├── routers/
│   ├── services/
│   └── main.py
├── vercel.json                 # Vercel configuration
└── README.md
```

## Features in Detail

### Interactive Visualizations
- Real-time parameter adjustments with sliders
- Animated physics and chemistry simulations
- Interactive charts and graphs
- Step-by-step process explanations

### Educational Focus
- Clear visual labels and values on diagrams
- Detailed explanations for students
- Progress indicators for step-by-step processes
- Responsive design for all screen sizes

### User Interface
- Dark theme for comfortable viewing
- Sidebar navigation with subject dropdowns
- Clickable title to navigate home
- Back button on all pages

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Dileep Tekkali**
- GitHub: [@DileepTekkali](https://github.com/DileepTekkali)

## Acknowledgments

- Flutter team for the amazing UI framework
- All contributors and open-source libraries used in this project
- Students and educators who provided feedback

---

⭐ If you found this project useful, please give it a star!
