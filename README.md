# Math & Science Visualizer

An interactive web application for visualizing mathematical and scientific concepts through dynamic simulations, calculators, and educational tools.

![Flutter](https://img.shields.io/badge/Flutter-3.27.0-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.7.0-0175C2?style=for-the-badge&logo=dart)
![Python](https://img.shields.io/badge/Python-3.11-3776AB?style=for-the-badge&logo=python)
![FastAPI](https://img.shields.io/badge/FastAPI-0.111-009688?style=for-the-badge&logo=fastapi)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

## Live Demo

**https://dileeptekkali.github.io/Interactive-visualizer/**

## Features

### Mathematics
- **Linear Equations** - Graph linear functions with slope-intercept form
- **Quadratic Equations** - Visualize parabolas and analyze roots
- **Calculus** - Explore derivatives and integrals interactively
- **Trigonometry** - Interactive unit circle and trigonometric functions
- **Geometry** - Shape properties and area/volume calculations
- **Complex Numbers** - Visualize operations on the complex plane
- **Vectors** - Vector addition and resultant calculations
- **Coordinate Geometry** - Distance, midpoint, and section formulas
- **Progressions** - Arithmetic and geometric sequences
- **Linear Programming** - Optimize objective functions graphically
- **Circles** - Circle properties and tangent calculations
- **Conic Sections** - Parabola, ellipse, and hyperbola
- **Statistics** - Data visualization and statistical analysis
- **Data Handling** - Charts and data representation
- **Number Line** - Visualize inequalities and intervals
- **Mensuration** - 2D/3D shape calculations

### Chemistry
- **Atom Builder** - Build atoms with protons, neutrons, and electrons
- **Periodic Table** - Explore element properties
- **Chemical Bonding** - Ionic, covalent, and metallic bonds
- **Reaction Kinetics** - Rate laws and concentration graphs
- **Equilibrium** - Le Chatelier's principle simulator
- **Thermodynamics** - Energy profile diagrams
- **Mole Calculator** - Convert between mass, moles, and particles
- **Separation Techniques** - Filtration and evaporation steps
- **Change Detector** - Physical vs chemical change classifier

### Physics
- **Motion Graphs** - Position, velocity, and acceleration
- **Newton's Laws** - Force and motion simulations
- **Friction** - Friction coefficient calculations
- **Heat Transfer** - Conduction, convection, and radiation
- **Wave Simulator** - Wave properties and interference
- **Optics** - Light reflection and refraction
- **Circuit Simulator** - Series and parallel circuits
- **Magnetic Field** - Electromagnetic field visualization
- **Energy Simulator** - Energy conservation demonstrations
- **Lever Machine** - Mechanical advantage calculator

## Tech Stack

### Frontend
- **Flutter 3.27.0** - UI framework
- **Dart 3.7.0** - Programming language
- **fl_chart** - Interactive charts and graphs
- **google_fonts** - Custom typography

### Backend
- **Python 3.11** - API server
- **FastAPI** - REST API framework
- **NumPy** - Numerical computations

## Getting Started

### Prerequisites
- Flutter SDK 3.27.0 or higher
- Python 3.11 or higher
- Git

### Frontend Setup

```bash
# Clone the repository
git clone https://github.com/DileepTekkali/Interactive-visualizer.git
cd Interactive-visualizer/frontend

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Backend Setup

```bash
# Navigate to backend
cd backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run the server
uvicorn main:app --reload
```

### Build for Web

```bash
cd frontend
flutter build web
```

The build output will be in `frontend/build/web/`.

## Project Structure

```
Interactive-visualizer/
├── frontend/
│   ├── lib/
│   │   ├── core/              # Theme and constants
│   │   ├── features/          # Feature modules
│   │   │   ├── calculus/
│   │   │   ├── chemistry/
│   │   │   ├── geometry/
│   │   │   ├── physics/
│   │   │   └── ...
│   │   └── shared/            # Reusable widgets and services
│   └── web/                   # Web-specific assets
├── backend/
│   ├── routers/               # API endpoints
│   ├── services/              # Business logic
│   └── main.py                # FastAPI application
└── README.md
```

## API Endpoints

### Chemistry
- `GET /api/chemistry/atom/{symbol}` - Element data
- `GET /api/chemistry/bond?el1=X&el2=Y` - Bond type
- `GET /api/chemistry/kinetics` - Reaction kinetics
- `GET /api/chemistry/equilibrium` - Equilibrium simulation
- `GET /api/chemistry/thermodynamics` - Energy profiles
- `POST /api/chemistry/mole_calculator` - Mole calculations

### Physics
- `GET /api/physics/friction` - Friction calculations
- `GET /api/physics/motion` - Motion parameters
- `GET /api/physics/energy` - Energy simulations
- And more...

### Mathematics
- `POST /api/linear` - Linear equation analysis
- `POST /api/quadratic` - Quadratic equation analysis
- `POST /api/calculus` - Calculus operations
- `POST /api/trig` - Trigonometric calculations
- And more...

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
- FastAPI for the high-performance backend
- All contributors and open-source libraries used in this project

---

⭐ If you found this project useful, please give it a star!
