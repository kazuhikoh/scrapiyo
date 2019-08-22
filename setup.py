import setuptools

with open('requirements') as requirements_file:
    install_requirements = requirements_file.read().splitlines()

setuptools.setup(
    name="scrapiyo",
    version="1.0.0",
    description="Piyo Scraper",
    author="kazuhikoh",
    packages=setuptools.find_packages(),
    python_requires='>=3.5',
    install_requires=install_requirements,
    entry_points={
        "console_scripts": [
            "scrapiyo=scrapiyo:main"
        ]
    }
)
