// The Flock (a list of Boid objects)

class Flock {
  ArrayList<Boid> boids; // An ArrayList for all the boids

    Flock() {
    boids = new ArrayList<Boid>(); // Initialize the ArrayList
  }

  void run() {
    for (Boid b : boids) {
      b.run(boids);  // Passing the entire list of boids to each boid individually
    }
  }

  void addBoid(Boid b) {
    if (boids.size() <= 600) {
      boids.add(b);
    }
  }

  void killRandomBoid() {
    if ( boids.size() > 1 ) {
      Boid victim = boids.get( floor(random(boids.size())) );
      boids.remove(victim);
    }
  }

  void killAll() {
    boids.clear();
  }
}
