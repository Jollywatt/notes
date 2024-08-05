using GeometricAlgebra
using BladeBasedModels.Conformal
using Geomviz
using Random

const o, oo = nullbasis(3)
@basis 3

Base.abs2(a::AbstractMultivector) = a⊙~a

function render_and_save(name)
    Geomviz.send_to_server((
        render=(
            filepath=joinpath(dirname(@__FILE__), name),
        ),
    ))
end


function sphere_point_kiss(seed=21)
    Random.seed!(seed)
    A = (o + 2\oo)∧v123
    B = up((v1 + v3)/√2)
    C = inner(A, B)/2

    geomviz([
        Styled(A, color=(0,0.5,1,1))
        Styled(B, color=(1,0.2,0,1))
        Styled(C, "Arrow count"=>0)
        Styled(ipns(C), color=(1,1,0,1), "Arrow count"=>0)
    ])
    render_and_save("sphere-point-kiss.png")
end
function sphere_point_miss(seed=7)
    Random.seed!(seed)
    A = (o + 2\oo)∧v123
    B = translate((v1 + 1.8v3)/√2, o)
    C = inner(A, B)/2

    geomviz([
        Styled(A, color=(0,0.5,1,0.8))
        Styled(B, color=(1,0.2,0,1))
        opns(C)
        Styled(ipns(C), color=(1,1,0,1), "Point size"=>0.02)
    ])
    render_and_save("sphere-point-miss.png")
end

function sphere_vector_kiss(seed=7)
    Random.seed!(seed)
    A = (o + 2\oo)∧v123
    B = translate((v1 + v3)/√2, o∧-v2)
    C = inner(A, B)/2

    geomviz([
        Styled(A, color=(0,0.5,1,1))
        Styled(B, color=(1,0.2,0,1))
        C
        Styled(ipns(C), color=(1,1,0,1), "Arrow count"=>0)
    ])
    render_and_save("sphere-vector-kiss.png")
end
function sphere_vector_miss(seed=7)
    Random.seed!(seed)
    A = (o + 2\oo)∧v123
    B = translate((v1 + 1.6v3)/√2, o∧v2)
    C = inner(A, B)/2

    geomviz([
        Styled(A, color=(0,0.5,1,0.8))
        Styled(B, color=(1,0.2,0,1))
        opns(C)
        Styled(ipns(C), color=(1,1,0,1))
        
    ])
    render_and_save("sphere-vector-miss.png")
end

function sphere_bivector_kiss(seed=7)
    Random.seed!(seed)
    A = (o + 2\oo)∧v123
    B = translate((v1 + v3)/√2, o∧(v12 + v23))/3
    C = inner(A, B)


    geomviz([
        Styled(A, color=(0,0.5,1,1))
        Styled(B, color=(1,0.2,0,1), "Arrow count"=>0)
        opns(C)
        Styled(ipns(-C), color=(1,1,0,1), "Arrow count"=>0)
    ])
    render_and_save("sphere-bivector-kiss.png")
end
function sphere_bivector_miss(seed=7)
    Random.seed!(seed)
    A = (o + 2\oo)∧v123
    B = translate((v1 + 1.6v3)/√2, o∧v12)/3
    C = inner(A, B)

    geomviz([
        Styled(A, color=(0,0.5,1,1))
        Styled(B, color=(1,0.2,0,1), "Arrow count"=>0)
        Styled(opns(C), "Resolution"=>16)
        Styled(ipns(C), color=(1,1,0,1), "Arrow count"=>0)
    ])
    render_and_save("sphere-bivector-miss.png")
end


function sphere_pointpair(seed=21)
    Random.seed!(seed)
    A = (o + 2\oo)∧v123
    B = translate((v1 + v3 - 0.2v2)/√2, (o + 0.1oo)∧(v3))
    C = inner(A, B)/2
    
    geomviz([
        Styled(A, color=(0,0.5,1,0.8))
        Styled(B, color=(1,0.2,0,1))
        Styled(opns(C), "Arrow count"=>0)
        Styled(ipns(C), color=(1,1,0,1), "Arrow count"=>0)
    ])
    render_and_save("sphere-pointpair.png")
end
function sphere_circle(seed=21)
    Random.seed!(seed)
    A = (o + 2\oo)∧v123
    B = translate((v1 + v3)/√2, (o + 0.1oo)∧v12)
    C = inner(A, B)/2

    geomviz([
        Styled(A, color=(0,0.5,1,0.8))
        Styled(B, color=(1,0.2,0,1))
        Styled(opns(C), "Arrow count"=>0, "Resolution"=>32)
        Styled(ipns(C), color=(1,1,0,1), "Arrow count"=>0)
    ])
    render_and_save("sphere-circle.png")
end
    

function circle_point_kiss(seed=21)
    Random.seed!(seed)
    A = (o + 2\oo)∧v12
    B = -up(-v2)
    C = inner(A, B[1])

    geomviz([
        Styled(A, color=(0,0.5,1,1))
        Styled(B, color=(1,0.2,0,1))
        opns(C)
        Styled(ipns(C/3), color=(1,1,0,0.2), "Arrow count"=>0)
    ])    
    render_and_save("circle-point-kiss.png")
end
function circle_point_miss(seed=21)
    Random.seed!(seed)
    A = (o + 2\oo)∧v12
    B = -up(-0.7v1 + 0.5v3)
    C = inner(A, B[1])

    geomviz([
        Styled(A, color=(0,0.5,1,1))
        Styled(B, color=(1,0.2,0,1))
        opns(C)
        Styled(ipns(C/3), color=(1,1,0,0.2), "Arrow count"=>0)
    ])    
    render_and_save("circle-point-miss.png")
end


function circle_pointpair(seed=21)
    Random.seed!(seed)
    A = (o + 2\oo)∧v12
    B = translate(v2 + 0.2v3, (o + 0.15oo)∧v1)
    C = inner(A, B)/2
    
    geomviz([
        Styled(A, color=(0,0.5,1,0.8))
        Styled(B, color=(1,0.2,0,1))
        Styled(opns(C), "Arrow count"=>0, "Resolution"=>10)
        Styled(ipns(C), color=(1,1,0,0.8), "Arrow count"=>0)
    ])
    render_and_save("circle-pointpair.png")
end



function test()
    A = (o + 2\oo)∧v12
    B = translate(0v1, (o + 2\oo)∧v12)
    C = inner(A, B)/2
    display((C))

    geomviz([
        Styled(A, color=(0,0.5,1,0.8))
        Styled(B, color=(1,0.2,0,1))
        # (C)
        # Styled(ipns(C), color=(1,1,0,1))
    ])

end


function main()
    println(".")

    sphere_point_kiss()
    sphere_point_miss()

    sphere_vector_kiss()
    sphere_vector_miss()

    sphere_bivector_kiss()
    sphere_bivector_miss()

    sphere_pointpair()
    sphere_circle()

    circle_point_kiss()
    circle_point_miss()
end

const lasttime = Ref(time())
init() = Revise.entr([@__FILE__]) do
    if time() - lasttime[] < 1
        return
    end
    main()
    lasttime[] = time()
end