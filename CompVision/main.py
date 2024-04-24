import cv2
import numpy as np
import numpy.ma as ma

def get_field(img):
    """
    Finds the playing field in the image

    Args:
        img: np.array object of shape (WxHx3) that represents the BGR value of the
        frame pixels .

    Returns:
        Masked Image with only the playing field
        Coordinates of center of field to act as tether
            
    """
    # Convert image to HSV color space
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

    # Define range of green color in HSV
    lower_green = np.array([30, 40, 40])
    upper_green = np.array([80, 255, 255])

    # Threshold the HSV image to get only green colors
    mask = cv2.inRange(hsv, lower_green, upper_green)
    mass_y, mass_x = np.where(mask >= 255)
    # mass_x and mass_y are the list of x indices and y indices of field pixels

    cent_x = np.average(mass_x)
    cent_y = np.average(mass_y)

    masked_img = cv2.bitwise_and(img, img, mask=mask)

    return masked_img, (cent_x, cent_y)


if __name__ == "__main__":

    img = cv2.imread("img7.png")
    masked_img, center_pt = get_field(img)

    cent_x, cent_y = center_pt
    print("x, y:", cent_x, cent_y)
    cv2.namedWindow("Ground_Img",cv2.WINDOW_NORMAL)
    cv2.imshow("Ground_Img", masked_img)
    cv2.waitKey(0)
    #img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)    
    #img_canny = cv.Canny(model_gray, c_t1, c_t2)
    #model_lines = cv.cvtColor(model_canny, cv.COLOR_GRAY2BGR)
    #source_lines = cv.HoughLines(model_canny, 1.1, h_theta, 247, h_lines, h_srn, h_stn)

    cv2.destroyAllWindows()
