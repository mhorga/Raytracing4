
import CoreImage
import simd

public struct Pixel {
    var r: UInt8
    var g: UInt8
    var b: UInt8
    var a: UInt8
    public init(red: UInt8, green: UInt8, blue: UInt8) {
        r = red
        g = green
        b = blue
        a = 255
    }
}

public func imageFromPixels(width: Int, _ height: Int) -> CIImage {
    var pixel = Pixel(red: 0, green: 0, blue: 0)
    var pixels = [Pixel](count: width * height, repeatedValue: pixel)
    var objects = [Hitable]()
    var object = Sphere(c: float3(0, -100.5, -1), r: 100, m: Lambertian(albedo: float3(0.7, 0.23, 0.12)))
    objects.append(object)
    object = Sphere(c: float3(1, 0, -1), r: 0.5, m: Metal(albedo: float3(0.8, 0.6, 0.2), fuzz: 0.1))
    objects.append(object)
    object = Sphere(c: float3(-1, 0, -1), r: 0.5, m: Dielectric())
    objects.append(object)
    object = Sphere(c: float3(-1, 0, -1), r: -0.49, m: Dielectric())
    objects.append(object)
    object = Sphere(c: float3(0, 0, -1), r: 0.5, m: Lambertian(albedo: float3(0.24, 0.5, 0.15)))
    objects.append(object)
    let world = Hitable_list(list: objects)
    let lookFrom = float3(0, 1, -4)
    let lookAt = float3()
    let cam = Camera(lookFrom: lookFrom, lookAt: lookAt, vup: float3(0, -1, 0), vfov: 50, aspect: Float(width) / Float(height))
    for i in 0..<width {
        for j in 0..<height {
            var col = float3()
            let ns = 10
            for _ in 0..<ns {
                let u = (Float(i) + Float(drand48())) / Float(width)
                let v = (Float(j) + Float(drand48())) / Float(height)
                let r = cam.get_ray(u, v)
                col += color(r, world, 0)
            }
            col /= float3(Float(ns))
            col = float3(sqrt(col.x), sqrt(col.y), sqrt(col.z))
            pixel = Pixel(red: UInt8(col.x * 255), green: UInt8(col.y * 255), blue: UInt8(col.z * 255))
            pixels[i + j * width] = pixel
        }
    }
    let bitsPerComponent = 8
    let bitsPerPixel = 32
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue) // alpha is last
    let providerRef = CGDataProviderCreateWithCFData(NSData(bytes: pixels, length: pixels.count * sizeof(Pixel)))
    let image = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, width * sizeof(Pixel), rgbColorSpace, bitmapInfo, providerRef, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
    return CIImage(CGImage: image!)
}