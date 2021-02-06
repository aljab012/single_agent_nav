//Vector Library [3D]
//CSCI 5611 Vector 3 Library
// Declan Buhrsmith <buhrs001@umn.edu>

public class Vec3 {
  public float x, y, z;

  public Vec3(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  public String toString() {
    return "(" + x + "," + y + "," + z + ")";
  }

  public float length() {
    return sqrt((x*x)+(y*y)+(z*z));
  }

  public Vec3 plus(Vec3 rhs) {
    return new Vec3(x+rhs.x, y+rhs.y, z+rhs.z);
  }

  public void add(Vec3 rhs) {
    x += rhs.x;
    y += rhs.y;
    z += rhs.z;
  }

  public Vec3 minus(Vec3 rhs) {
    return new Vec3(x-rhs.x, y-rhs.y, z-rhs.z);
  }

  public void subtract(Vec3 rhs) {
    x -= rhs.x;
    y -= rhs.y;
    z -= rhs.z;
  }

  public Vec3 times(float rhs) {
    return new Vec3(x*rhs, y*rhs, z*rhs);
  }

  public void mul(float rhs) {
    x *= rhs;
    y *= rhs;
    z *= rhs;
  }

  public void normalize() {
    float magnitude = sqrt((x*x)+(y*y)+(z*z));
    x /= magnitude;
    y /= magnitude;
    z /= magnitude;
  }

  public Vec3 normalized() {
    float magnitude = sqrt((x*x)+(y*y)+(z*z));
    return new Vec3(x/magnitude, y/magnitude, z/magnitude);
  }

  public float distanceTo(Vec3 rhs) {
    float dx = rhs.x + x;
    float dy = rhs.y + y;
    float dz = rhs.z + z;
    return sqrt((dx*dx)+(dy*dy)+(dz*dz));
  }

  public float dist(Vec3 rhs) {
    float dx = x - rhs.x;
    float dy = y - rhs.y;
    float dz = z - rhs.z;
    return (float) Math.sqrt(dx*dx + dy*dy + dz*dz);
  }

  public Vec3 copy() {
    return new Vec3(x, y, z);
  }
  // note this is worong!
  public float heading() {
    float angle = (float) Math.atan2(z, x);
    return angle;
  }
}

Vec3 interpolate(Vec3 a, Vec3 b, float t) {
  return a.plus((b.minus(a)).times(t));
}

float dot(Vec3 a, Vec3 b) {
  return (a.x*b.x)+(a.y*b.y)+(a.z*b.z);
}

Vec3 cross(Vec3 a, Vec3 b) {
  return new Vec3(((a.y*b.z)-(a.z*b.y)), ((a.x*b.z)-(a.z*b.x)), ((a.x*b.y)-(a.y*b.x)));
}

Vec3 projAB(Vec3 a, Vec3 b) {
  return b.times((a.x*b.x)+(a.y*b.y)+(a.z*b.z));
}
